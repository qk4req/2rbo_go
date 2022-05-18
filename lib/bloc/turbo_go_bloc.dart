import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:keyboard_service/keyboard_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:http/http.dart' as http;



import '../controllers/driver_controller.dart';
import '../controllers/timestamp_controller.dart';
import 'turbo_go_event.dart';
import 'turbo_go_state.dart';
import '/controllers/client_controller.dart';
import '/controllers/tariff_controller.dart';
import '/controllers/order_controller.dart';
import '/controllers/drivers_online_controller.dart';
import '/models/order_model.dart';
import '/models/tariff_model.dart';



class TurboGoBloc extends Bloc<TurboGoEvent, TurboGoState> {
  static YandexMapController? mapController;
  static TimestampController? timestampController;
  static DriverController driverController = DriverController();
  static DriversOnlineController driversOnlineController = DriversOnlineController();
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
        'deviceId': clientController.clientModel!.deviceId
      });
      socket.emit('driversOnline.read');
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

    /*orderController.repo.watch().listen((event) {
      if (orderController.repo.isNotEmpty) {
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
      }
    });*/

    on<TurboGoEvent>(_onEvent, transformer: sequential());
    timestampController = TimestampController();
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
          socket.connect();
        }
      );
    }

    if (event is TurboGoStartOfLocationChangeEvent) {
      KeyboardService.dismiss();
      if (state is TurboGoLocationHasChangedState) {
        TurboGoState prevState = (state as TurboGoLocationHasChangedState).prevState;

        if (prevState is TurboGoPointsState) {
          orderController.updateNewOrder(
            prevState.type == LocationType.start ? {'from': {}} : {'whither': {}},
            false
          );
        }
      } else {
        emit(TurboGoLocationHasChangedState(state));
      }
    }

    if (event is TurboGoEndOfLocationChangeEvent) {
      if (state is TurboGoLocationHasChangedState) {
        TurboGoState prevState = (state as TurboGoLocationHasChangedState).prevState;
        if (prevState is TurboGoHomeState) {
          //http.get(Uri.parse('API_URL')).then((res) {

          //}).catchError((error) {
            orderController.updateNewOrder({
              'from': {
                'type': 'Point',
                'coordinates': [event.point.latitude, event.point.longitude]
              }
            });
          //});
        }

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
        }

        emit(prevState);
      } else {
        orderController.updateNewOrder({
          'from': {
            'type': 'Point',
            'coordinates': [event.point.latitude, event.point.longitude]
          },
          //'whither': {}
        });
        emit(TurboGoHomeState());
      }
    }

    if (event is TurboGoChangeStartPointEvent) {
      if (state is TurboGoPointsState) {
        (state as TurboGoPointsState).type = LocationType.start;
      } else {
        emit(TurboGoPointsState(LocationType.start));
      }
    }

    if (event is TurboGoChangeEndPointEvent) {
      if (state is TurboGoPointsState) {
        (state as TurboGoPointsState).type = LocationType.end;
      } else {
        emit(TurboGoPointsState(LocationType.end));
      }
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
      orderController.updateNewOrder({
        'clientId': clientController.clientModel?.id,
        'driverId': driversOnlineController.repo.values.first.driver['id'],
        'carId': driversOnlineController.repo.values.first.driver['car']['id'],
        'status': 'submitted'
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



    //DRIVERS ONLINE
    socket.on('driversOnline.read', (data) {
      if (data['success']) {
        List drivers = data['payload'];

        for (Map d in drivers) {
          if (!driverController.contains(d)) {
            driverController.create(d['driver']);
            /*Map tariff = d['driver']['car']['tariff'];
            if (!tariffController.contains(tariff)) {
              tariffController.create(tariff);
            } else {
              if (!tariffController.compare(tariff)) {
                tariffController.update(tariff);
              }
            }*/
          }
          if (!driversOnlineController.contains(d)) {
            driversOnlineController.create(d);
          } else {
            if (!driversOnlineController.compare(d)) {
              driversOnlineController.update(d);
            }
          }
        }
      }
    });

    socket.on('driversOnline.update', (data) {
      if (data['success']) {
        Map driver = data['payload'];
        if (driversOnlineController.contains(driver) && !driversOnlineController.compare(driver)) {
          driversOnlineController.update(driver);
        }
      }
    });

    socket.on('drivers.update', (data) {
      if (data['success']) {
        Map driver = data['payload'];
        if (driverController.contains(driver) && !driverController.compare(driver)) {
          driverController.update(driver);
        }
      }
    });



    //ORDERS
    /*socket.on('orders.create', (data) {
      if (data['success']) {
        Map order = data['payload'];
        if (order['clientId'] == clientController.clientModel!.id) {
          orderController.create(order);
        }
      } else {
      }
    });*/

    socket.on('orders.update', (data) {
      if (data['success']) {
        Map order = data['payload'];
        if (orderController.contains(order) && !orderController.compare(order)) {
          orderController.update(order);
        }
      }
    });
  }
}