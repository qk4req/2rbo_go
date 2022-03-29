import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:keyboard_service/keyboard_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:turbo_go/main.dart';
import 'package:turbo_go/models/driver_model.dart';
import 'package:turbo_go/widgets/map_widget.dart';
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
  static const String apiUrl = 'http://10.0.2.2:3001';

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

  TurboGoBloc(TurboGoState initialState) : super(initialState) {
    socket.onConnect((_) {
      print("Success! onConnect");
      socket.emit('clients.read');
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

    on<TurboGoEvent>(_onEvent, transformer: sequential());
  }

  FutureOr<void> _onEvent(TurboGoEvent event, Emitter<TurboGoState> emit) async {
    if (event is TurboGoStartEvent) {
      _registerHandlers(emit);
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      clientController.update({
          'key': appKey,
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
        if (prevState is TurboGoTariffsState) {
          emit(prevState);
        }
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
      //mapController.
      emit(TurboGoTariffsState());
    }
  }
  
  _registerHandlers(Emitter<TurboGoState> emit) {
    socket.on('clients.read', (data) {
      if (data['success']) {
        Map client = data['payload'];
        if (!clientController.compare(client)) {
          clientController.update(client);
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
    /*socket.on('orders.create', (data) {
      if (data['success']) {
        Map o = data['payload'];
        OrderModel order = OrderModel.fromJson(o);
        //DriverController.repo.put('status', 'busy');
        OrderController.repo.put(order.id, order);
      } else {
        emit(TurboAuthErrorState(errorText: data['payload']));
      }
    });

    socket.on('orders.update', (data) {
      if (data['success']) {
        Map o = data['payload'];
        OrderModel newOrder = OrderModel.fromJson(o);
        if (OrderController.repo.containsKey(newOrder.id)) {
          OrderModel oldOrder = OrderController.repo.get(newOrder.id)!;
          oldOrder.driverId = newOrder.driverId;
          oldOrder.clientId = (oldOrder.clientId != null && newOrder.clientId == null ? oldOrder.clientId : newOrder.clientId);
          oldOrder.status = newOrder.status;
          OrderController.repo.put(oldOrder.id, oldOrder);
        }
      } else {
        emit(TurboAuthErrorState(errorText: data['payload']));
      }
    });


    //ZONES
    socket.on('zones.read', (data) {
      if (data['success']) {
        List zones = data['payload'];
        if (zones.isNotEmpty) {
          Iterable<ZoneModel> zonesIterable = Iterable.generate(zones.length, (k) {
            Map z = zones[k];

            return(ZoneModel.fromJson(z));
          });
          for (ZoneModel z in zonesIterable) {
            if (ZoneController.repo.containsKey(z.id)) {
              ZoneModel zone = ZoneController.repo.get(z.id)!;
              zone.name = z.name;
              zone.polygon = z.polygon;
              zone.multiplier = z.multiplier;
              ZoneController.repo.put(zone.id, zone);
            } else {
              ZoneController.repo.put(z.id, z);
            }
          }
        }
      }
    });*/
  }
}