import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:keyboard_service/keyboard_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'turbo_go_event.dart';
import 'turbo_go_state.dart';
import '/controllers/client_controller.dart';
import '/controllers/tariff_controller.dart';
import '/controllers/order_controller.dart';
import '/controllers/driver_controller.dart';
import '/models/order_model.dart';
import '/models/tariff_model.dart';



class TurboGoBloc extends Bloc<TurboGoEvent, TurboGoState> {
  static YandexMapController? mapController;
  static DriverController driverController = DriverController();
  static ClientController clientController = ClientController();
  static TariffController tariffController = TariffController();
  static OrderController orderController = OrderController();

  //static const int apiReconnectionDelay = 1000;
  static const String apiUrl = 'http://10.0.2.2:3000';

  static io.Socket socket = io.io(
      '$apiUrl/users',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
      //.setReconnectionDelay(API_RECONNECTION_DELAY)
      //.setReconnectionAttempts(1)
          .setTimeout(5000)
          .build()
  );
  Timer? _timer;

  TurboGoBloc(TurboGoState initialState) : super(initialState) {
    socket.onConnect((_) {
      print("Success! onConnect");
      socket.emit('clients.read', {
        'deviceId': clientController.clientModel?.deviceId
      });
      socket.emit('drivers.read');
      socket.emit('tariffs.read');
      emit(TurboGoConnectedState());
    });
    socket.onConnectError((_) {
      print("Error! onConnectError");
      emit(TurboGoNotConnectedState());
    });
    socket.onDisconnect((_) {
      print("Error! onDisconnect");
      emit(TurboGoNotConnectedState());
    });

    orderController.repo.watch().listen((event) {
      OrderModel? last = orderController.getLast();

      if (last?.status == 'confirmed') {
        emit(TurboGoDriverState());
      }
      if (last?.status == 'submitted') {
        if (_timer == null) {
          Timer(const Duration(seconds: 30), () {
            //WE SEND TO THE NEXT DRIVER
          });
        }
      }
    });

    on<TurboGoEvent>(_onEvent, transformer: sequential());
  }

  FutureOr<void> _onEvent(TurboGoEvent event, Emitter<TurboGoState> emit) async {
    if (event is TurboGoStartEvent) {
      _registerHandlers(emit);
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      clientController.update({
          'deviceId': androidInfo.androidId
        },
        () {
          socket.io.options['query'] = {
            'jwt': jsonEncode(clientController.repo.toMap())
          };
          socket.connect();
        }
      );
    }

    if (event is TurboGoStartOfLocationChangeEvent) {
      KeyboardService.dismiss();
      if (state is! TurboGoLocationHasChangedState) {
        emit(TurboGoLocationHasChangedState(state));
      }
    }

    if (event is TurboGoEndOfLocationChangeEvent) {
      if (state is TurboGoLocationHasChangedState) {
        TurboGoState prevState = (state as TurboGoLocationHasChangedState).prevState;
        //if (prevState is TurboGoHomeState) {
        //  emit(prevState);
        //}
        if (prevState is TurboGoPointsState) {
          if (prevState.type == LocationType.start) {
            orderController.updateNewOrder({
              'from': {
                'type': 'Point',
                'coordinates': [event.point.latitude, event.point.longitude]
              }
            });
          } else {
            orderController.updateNewOrder({
              'whither': {
                'type': 'Point',
                'coordinates': [event.point.latitude, event.point.longitude]
              }
            });
          }
          emit(prevState);
        }
        //if (prevState is TurboGoTariffsState) {
          emit(prevState);
        //}
      } else {
        orderController.updateNewOrder({
          'from': {
            'type': 'Point',
            'coordinates': [event.point.latitude, event.point.longitude]
          }
        });
        emit(TurboGoPointsState(LocationType.start));
      }
    }

    if (event is TurboGoChangeStartPointEvent) {
      if (state is TurboGoPointsState) {
        (state as TurboGoPointsState).type = LocationType.start;
      }
      emit(TurboGoExtendedPointsState(LocationType.start));
    }

    if (event is TurboGoChangeEndPointEvent) {
      if (state is TurboGoPointsState) {
        (state as TurboGoPointsState).type = LocationType.end;
      }
      emit(TurboGoExtendedPointsState(LocationType.end));
    }

    //if (event is TurboGoFindEndPointsEvent) {
    //}

    if (event is TurboGoSelectTariffEvent) {
      int? defaultTariffId;
      if (event.tariffId == null && tariffController.repo.isNotEmpty) {
        TariffModel? t = tariffController.repo.values.first;

        defaultTariffId = t.id;
      }
      orderController.updateNewOrder({
          'tariffId': event.tariffId ?? defaultTariffId
        }
      );

      emit(TurboGoTariffsState());
    }

    if (event is TurboGoFindDriverEvent) {
      socket.emit('orders.create', {
        'clientId': clientController.clientModel?.id,
        'driverId': driverController.repo.values.first.id,
        'from': orderController.newOrder.from,
        'whither': orderController.newOrder.whither,
        'comment': orderController.newOrder.comment,
        'status': 'submitted',
      });

      emit(TurboGoSearchState());
    }
  }
  
  _registerHandlers(Emitter<TurboGoState> emit) {
    //CLIENTS
    socket.on('clients.read', (data) {
      if (data['success']) {
        List client = data['payload'];
        if (client.isNotEmpty && !clientController.compare(client.first)) {
          clientController.update(client.first);
        }
      } else {
        socket.emit('clients.create');
      }
    });

    socket.on('clients.update', (data) {
      if (data['success']) {
        Map client = data['payload'];
        clientController.update(client);
      }
    });



    //TARIFFS
    socket.on('tariffs.read', (data) {
      if (data['success']) {
        List tariffs = data['payload'];
        for (Map t in tariffs) {
          if (!tariffController.contains(t)) {
            tariffController.create(t);
          } else {
            if (!tariffController.compare(t)) {
              tariffController.update(t);
            }
          }
        }
      }
    });



    //DRIVERS
    socket.on('drivers.read', (data) {
      if (data['success']) {
        List drivers = data['payload'];
        for (Map d in drivers) {
          if (!driverController.contains(d)) {
            driverController.create(d);
          } else {
            if (!driverController.compare(d)) {
              driverController.update(d);
            }
          }
        }
      }
    });
    socket.on('drivers.update', (data) {
      if (data['success']) {
        Map driver = data['payload'];
        driverController.update(driver);
      }
    });



    //ORDERS
    socket.on('orders.create', (data) {
      if (data['success']) {
        Map order = data['payload'];
        orderController.create(order);
      } else {
      }
    });

    socket.on('orders.update', (data) {
      if (data['success']) {
        Map order = data['payload'];
        orderController.update(order);
      }
    });
  }
}