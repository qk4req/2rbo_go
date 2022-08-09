import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:keyboard_service/keyboard_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:http/http.dart' as http;
import 'package:turbo_go/controllers/geocoder_controller.dart';
import 'package:turbo_go/controllers/notification_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';


import 'turbo_go_event.dart';
import 'turbo_go_state.dart';
import '/controllers/client_controller.dart';
import '/controllers/tariff_controller.dart';
import '/controllers/order_controller.dart';
import '/controllers/drivers_online_controller.dart';
import '/controllers/flash_message_controller.dart';
import '/controllers/driver_controller.dart';
import '/controllers/timestamp_controller.dart';
import '/controllers/clients_online_controller.dart';
import '/models/tariff_model.dart';
import '/models/order_model.dart';



class TurboGoBloc extends Bloc<TurboGoEvent, TurboGoState> {
  static Version appVersion = Version.parse('1.0.0');
  static String DISPATCHER_PHONE_NUMBER = '+79678761243';

  static TimestampController? timestampController;
  static NotificationController notificationController = NotificationController();
  static DriverController driverController = DriverController();
  static DriversOnlineController driversOnlineController = DriversOnlineController();
  static ClientController clientController = ClientController();
  static ClientsOnlineController clientsOnlineController = ClientsOnlineController();
  static TariffController tariffController = TariffController();
  static OrderController orderController = OrderController();
  static GeocoderController geocoderController = GeocoderController();
  static FlashMessageController flashMessageController = FlashMessageController();

  //static const int API_RECONNECTION_DELAY = 1000;
  static const String API_URL = 'http://185.119.58.157:3000';
  static const String GEOCODER_URL = 'https://nominatim.openstreetmap.org';

  static io.Socket socket = io.io(
      '$API_URL/users',
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
    timestampController = TimestampController();
    _registerHandlers();
    on<TurboGoEvent>(_onEvent, transformer: sequential());
    orderController.repo.watch().listen((event) {
      //OrderModel? last = orderController.findLast();

      //if (last != null && event.key == last) {
        _toState();
      //}
    });
  }

  void _toState() async {
    OrderModel? last = orderController.findLast();

    //if (last == null) {
      //add(TurboGoHomeEvent());
    //} else {
      switch (last?.status) {
        case 'refused':
          add(TurboGoSearchEvent());
          break;
        case 'confirmed':
        case 'active':
        case 'pause':
        case 'wait':
          if ([TurboGoSearchState, TurboGoDriverState].contains(state.runtimeType)) {
            add(TurboGoDriverEvent());
          }
          break;
        default:
          /*switch(state.runtimeType) {
            case TurboGoInitState:
            case TurboGoHomeState:
              add(TurboGoHomeEvent());
              break;
            case TurboGoPointsState:
              add((state as TurboGoPointsState).type == LocationType.start ? TurboGoChangeStartPointEvent() : TurboGoChangeEndPointEvent());
              break;
            case TurboGoTariffsState:
              add(const TurboGoTariffsEvent());
              break;
            case TurboGoSearchState:
              add(TurboGoSearchEvent());
              break;
            case TurboGoDriverState:
              add(TurboGoDriverEvent());
              break;
          }*/
          if ([TurboGoInitState, TurboGoNotConnectedState, TurboGoDriverState].contains(state.runtimeType)) {
            add(TurboGoHomeEvent());
          }
          // else {
          //  emit([TurboGoInitState, TurboGoConnectedState].contains(state.runtimeType) ? TurboGoHomeState() : state);
          //}
          break;
      }
    //}
  }

  FutureOr<void> _onEvent(TurboGoEvent event, Emitter<TurboGoState> emit) async {
    if (event is TurboGoStartEvent) {
      //emit(TurboGoNotConnectedState());
      /*DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      clientController.update({
          'deviceId': androidInfo.androidId
        },
        () {
          socket.connect();
        }
      );*/
      socket.connect();
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
      List coordinates = [event.point.latitude, event.point.longitude];

      if (state is TurboGoLocationHasChangedState) {
        TurboGoState prevState = (state as TurboGoLocationHasChangedState).prevState;

        if (prevState is TurboGoHomeState) {
          prevState.reset = false;

          /*http.get(Uri.parse(GeocoderController.buildReverseUrl(
            coordinates, Zooms.building
          ))).then((res) {
            Map data = jsonDecode(res.body.toString());
            Map from = {
              'type': 'Point',
              'coordinates': coordinates
            };
            if (data['address']['town'] is String && data['address']['road'] is String) {
              from.addEntries([
                MapEntry('desc', '${data['address']['town']}, ${data['address']['road']}${data['address']['house_number'] is String ? ', ${data['address']['house_number']}' : ''}')
              ]);
            }
            orderController.updateNewOrder({
              'from': from
            });
          }).catchError((error) {
            orderController.updateNewOrder({
              'from': {
                'type': 'Point',
                'coordinates': coordinates
              }
            });
          });*/
          geocoderController.reverse(coordinates);
        }

        if (prevState is TurboGoPointsState) {
          if (prevState.type == LocationType.start) {
            /*orderController.updateNewOrder({
              'from': {
                'type': 'Point',
                'coordinates': coordinates
              }
            });*/
            geocoderController.reverse(coordinates, CoordinateTypes.from);
          } else {
            /*orderController.updateNewOrder({
              'whither': {
                'type': 'Point',
                'coordinates': coordinates
              }
            });*/
            geocoderController.reverse(coordinates, CoordinateTypes.whither);
          }
        }

        emit(prevState);
      } else {
        //if (state is TurboGoDriverState) {
        //  orderController.createNewOrder();
        //  emit(TurboGoHomeState());
        //} else {
          /*http.get(Uri.parse(GeocoderController.buildReverseUrl(
              coordinates, Zooms.building
          ))).then((res) {
            Map data = jsonDecode(res.body.toString());
            Map from = {
              'type': 'Point',
              'coordinates': coordinates
            };

            if (data['address']['town'] is String && data['address']['road'] is String) {
              from.addEntries([
                MapEntry('desc', '${data['address']['town']}, ${data['address']['road']}${data['address']['house_number'] is String ? ', ${data['address']['house_number']}' : ''}')
              ]);
            }
            orderController.updateNewOrder({
              'from': from
            });
          }).catchError((error) {
            orderController.updateNewOrder({
              'from': {
                'type': 'Point',
                'coordinates': coordinates
              }
            });
          });*/
          /*orderController.updateNewOrder({
            'from': {
              'type': 'Point',
              'coordinates': [event.point.latitude, event.point.longitude]
            },
            //'whither': {}
          });*/
          geocoderController.reverse(coordinates);
          emit(TurboGoHomeState(false));
        //}
      }
    }

    if (event is TurboGoStartPointEvent) {
      if (state is TurboGoPointsState) {
        (state as TurboGoPointsState).type = LocationType.start;
      } else {
        emit(TurboGoPointsState(LocationType.start));
      }
    }
    if (event is TurboGoEndPointEvent) {
      if (state is TurboGoPointsState) {
        (state as TurboGoPointsState).type = LocationType.end;
      } else {
        emit(TurboGoPointsState(LocationType.end));
      }
    }

    if (event is TurboGoFindPointsEvent) {
      String? value = event.value;
      if (value is String && value.isNotEmpty) {
        geocoderController.search(value.split(RegExp(r'\s*[ ,.:]\s*')));
      }
    }

    if (event is TurboGoChangePointEvent) {
      if (event.type == LocationType.start) {
      }

      if (event.type == LocationType.end) {

      }
    }

    if (event is TurboGoHomeEvent) {
      orderController.createNewOrder();

      emit(TurboGoHomeState(true));
    }
    if (event is TurboGoTariffsEvent) {
      int? defaultTariffId;
      if (event.tariffId == null && tariffController.repo.isNotEmpty) {
        TariffModel? t = tariffController.repo.values.first;

        defaultTariffId = t.id;
      }
      orderController.updateNewOrder({
          'tariffId': event.tariffId ?? defaultTariffId
      });

      emit(TurboGoTariffsState());
    }
    if (event is TurboGoSearchEvent) {
      if (
        clientController.clientModel.phoneNumber != null &&
        clientController.clientModel.phoneNumber!.isNotEmpty
      ) {
        orderController.updateNewOrder({
          'clientId': clientController.clientModel.uuid,
          //'driverId': driversOnlineController.repo.values.first.driver['id'],
          //'carId': driversOnlineController.repo.values.first.driver['car']['id'],
          //'status': 'submitted'
          'status': 'search'
        });

        if (state is TurboGoSearchState) {
          (state as TurboGoSearchState).value = false;
        } else {
          emit(TurboGoSearchState(true));
        }
      } else {
        orderController.updateNewOrder({
          'clientId': clientController.clientModel.uuid,
          //'driverId': driversOnlineController.repo.values.first.driver['id'],
          //'carId': driversOnlineController.repo.values.first.driver['car']['id']
        });

        emit(TurboGoRegState());
      }
    }

    if (event is TurboGoAddClientDataEvent) {
      orderController.updateNewOrder({
        //'status': 'submitted'
        'status': 'search'
      });
      clientController.update(
        {
          'phoneNumber': event.phoneNumber
        }
      );

      emit(TurboGoSearchState(true, true));
    }

    if (event is TurboGoDriverEvent) {
      emit(TurboGoDriverState());
    }

    if (event is TurboGoNotSupportedEvent) {
      emit(TurboGoNotSupportedState(
        event.current, event.required, event.releaseNotes, event.upgradeUrl
      ));
    }
    
    if (event is TurboGoUpgradeAppEvent) {
      Uri _url = Uri.parse(event.upgradeUrl);

      await launchUrl(_url, mode: LaunchMode.externalApplication);
    }
  }

  _registerHandlers() {
    socket.onConnect((_) {
      print("Success! onConnect");
      //socket.emit('clients.read', {
      //  'uuid': clientController.clientModel.uuid
      //});
      socket.on('_', (data) async {
        socket.on('clients.update', (data) {
          if (data['success']) {
            Map client = data['payload'];
            if (client['uuid'] == clientController.clientModel.uuid && !clientController.compare(client)) {
              clientController.update(client, false);
            }
          }
        });

        socket.on('clientsOnline.read', (data) {
          if (data['success']) {
            List client = data['payload'];
            if (client.isNotEmpty/* && !clientsOnlineController.compare(client.first)*/) {
              clientsOnlineController.update(client.first);
              if (client.first['client'] != null) {
                clientController.update(client.first['client'], false);
              }
            } else {
              clientsOnlineController.create({
                'clientId': clientController.clientModel.uuid
              });
              clientController.create();
            }

            _toState();
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
        if (order['clientId'] == clientController.clientModel.id) {
          orderController.create(order);
        }
      } else {
      }
    });*/
        socket.on('orders.read', (data) {
          if (data['success']) {
            List orders = data['payload'];
            /*if (orderController.contains(order) && !orderController.compare(order)) {
              orderController.update(order, false);
            }*/
          }
        });

        socket.on('orders.update', (data) {
          if (data['success']) {
            Map order = data['payload'];
            if (orderController.contains(order) && !orderController.compare(order)) {
              orderController.update(order, false);
            }
          }
        });

        Version minVer = Version.parse(data['apps']['go']['minVersion']);
        if (appVersion >= minVer) {
          socket.emit('clientsOnline.read', {
            'clientId': clientController.clientModel.uuid
          });
          socket.emit('orders.read', [
            {
              'status': ['confirmed', 'active', 'pause', 'wait']
            },
            1,
            [['createdAt', 'DESC']]
          ]);
          socket.emit('driversOnline.read');
          socket.emit('tariffs.read');
        } else {
          add(TurboGoNotSupportedEvent(
            appVersion, minVer, data['apps']['go']['releaseNotes'], data['apps']['go']['upgradeUrl']
          ));
        }
      });
    });
    socket.onConnectError((_) {
      print("Error! onConnectError");
      //add(TurboGoStartEvent());
      //if (state is! TurboGoNotConnectedState) {
        emit(TurboGoNotConnectedState());
      //}
    });
    socket.onDisconnect((_) {
      print("Error! onDisconnect");
      //add(TurboGoStartEvent());
      //if (state is! TurboGoNotConnectedState) {
        emit(TurboGoNotConnectedState());
      //}
    });
    //CLIENTS
    /*socket.on('clients.read', (data) {
      if (data['success']) {
        List client = data['payload'];
        if (client.isNotEmpty && !clientController.compare(client.first)) {
          clientController.update(client.first);
        } else {
          clientController.create();
        }
      }
    });*/
  }
}