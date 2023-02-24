import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:turbo_go/controllers/clients_online_controller.dart';
import 'package:turbo_go/controllers/order_controller.dart';
import 'package:turbo_go/controllers/tariff_controller.dart';
import 'package:turbo_go/models/clients_online_model.dart';
import 'package:turbo_go/models/tariff_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:keyboard_service/keyboard_service.dart';

import '../../models/order_model.dart';
import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_event.dart';
import '/bloc/turbo_go_state.dart';
import '/controllers/driver_controller.dart';
import '/controllers/drivers_online_controller.dart';
import '/models/driver_model.dart';
import '/models/drivers_online_model.dart';

class MapFragment extends StatefulWidget {
  final bool fromReg;
  const MapFragment({Key? key, required this.fromReg}) : super(key: key);

  @override
  _MapFragmentState createState() => _MapFragmentState();
}

Point getCentralPoint(List<Point> geoCoordinates) {
  if (geoCoordinates.length == 1) {
    return geoCoordinates.first;
  }

  double x = 0;
  double y = 0;
  double z = 0;

  for (var geoCoordinate in geoCoordinates) {
    var latitude = geoCoordinate.latitude * pi / 180;
    var longitude = geoCoordinate.longitude * pi / 180;

    x += cos(latitude) * cos(longitude);
    y += cos(latitude) * sin(longitude);
    z += sin(latitude);
  }

  var total = geoCoordinates.length;

  x = x / total;
  y = y / total;
  z = z / total;

  var centralLongitude = atan2(y, x);
  var centralSquareRoot = sqrt(x * x + y * y);
  var centralLatitude = atan2(z, centralSquareRoot);

  return Point(latitude: centralLatitude * 180 / pi, longitude: centralLongitude * 180 / pi);
}

double getZoomLevel(List route) {
  double zoomLevel, minLat, minLong, maxLat, maxLong, latDiff, lngDiff, maxDiff;



  minLat = route.first[0];
  minLong = route.first[1];
  maxLat = route.first[0];
  maxLong = route.first[1];

  for (var point in route) {
    if(point[0] < minLat) minLat = point[0];
    if(point[0] > maxLat) maxLat = point[0];
    if(point[1] < minLong) minLong = point[1];
    if(point[1] > maxLong) maxLong = point[1];
  }
  latDiff = maxLat - minLat;
  lngDiff = maxLong - minLong;

  maxDiff = (lngDiff > latDiff) ? lngDiff : latDiff;
  if (maxDiff < (360 / pow(2, 20))) {
    zoomLevel = 21;
  } else {
    zoomLevel = (-1*( (log(maxDiff)/log(2)) - (log(360)/log(2))));
    if (zoomLevel < 1) {
      zoomLevel = 1;
    }
  }
  return zoomLevel;
}

final ClientsOnlineController clientsOnlineController = TurboGoBloc.clientsOnlineController;
final DriverController driverController = TurboGoBloc.driverController;
final DriversOnlineController driversOnlineController = TurboGoBloc.driversOnlineController;
final OrderController orderController = TurboGoBloc.orderController;
final TariffController tariffController = TurboGoBloc.tariffController;
final ClientsOnlineModel? clientsOnlineModel = TurboGoBloc.clientsOnlineController.clientsOnlineModel;

class _MapFragmentState extends State<MapFragment> with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  static YandexMapController? mapController;
  late Widget _map;
  static List<MapObject> _objects = [];
  static bool _zoomEnabled = true;
  static bool _scrollEnabled = true;
  static bool _fastTapEnabled = true;
  static bool _gesturesEnabled = true;
  static const double _defaultZoomLevel = 16.5;
  static final Map<String, Timer?> _timers = {

  };
  static bool triggeredCameraPosition = false;
  late bool fromReg;

  static void enableGestures() {
    _zoomEnabled = true;
    _scrollEnabled = true;
    _fastTapEnabled = true;
    _gesturesEnabled = true;
  }

  static void disableGestures() {
    _zoomEnabled = false;
    _scrollEnabled = false;
    _fastTapEnabled = false;
    _gesturesEnabled = false;
  }

  static void clearObjects() {
    _objects.clear();
  }

  static void clearPoints () {
    _objects.removeWhere((MapObject o) {
      return o.mapId.value.contains('point');
    });
  }

  /*static void hideAllDrivers () {
    //_objects = _objects.map<MapObject>((MapObject o) {

    //}).toList();
  }*/

  static CameraPosition _moveCamera(double lat, double lng, BuildContext context, [bool animated = false]) {
    CameraPosition position = CameraPosition(
        zoom: _defaultZoomLevel,
        target: Point(
            latitude: lat,
            longitude: lng
        )
    );

    mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
            position
        ),
        animation: animated ? const MapAnimation(type: MapAnimationType.smooth, duration: 2) : null
    );

    BlocProvider.of<TurboGoBloc>(context).add(TurboGoEndOfLocationChangeEvent(
        Point(latitude: position.target.latitude, longitude: position.target.longitude)
    ));

    return position;
  }

  static void defaultCameraPosition(BuildContext context, [bool animated = false]) {
    if (clientsOnlineModel?.location == null) {
      clientsOnlineController.repo.watch().listen((event) {
        if (!triggeredCameraPosition) {
          ClientsOnlineModel c = event.value;

          if (
            c.location?['coordinates'] is List &&
            c.location!['coordinates'][0] is double &&
            c.location!['coordinates'][1] is double
          ) {
            _moveCamera(c.location!['coordinates'][0], c.location!['coordinates'][1], context, animated);
            triggeredCameraPosition = true;
          }
        }
      });
    } else {
      _moveCamera(clientsOnlineModel!.location!['coordinates'][0], clientsOnlineModel!.location!['coordinates'][1], context);
    }
  }

  void cameraPositionCallback (CameraPosition position, CameraUpdateReason reason, finished) {
    KeyboardService.dismiss();
    if (
      _gesturesEnabled &&
      reason.name == 'gestures'// ||
      //(reason.name == 'application' && position.target.latitude == )
    ) {
      BlocProvider.of<TurboGoBloc>(context).add(TurboGoStartOfLocationChangeEvent());
      if (_timers['first'] != null) {
        _timers['first']!.cancel();
        _timers['first'] = null;
      }
      if (finished) {
        _timers.addAll({
          'first': Timer(const Duration(milliseconds: 500), () {
            mapController!.getCameraPosition().then((CameraPosition position) {
              BlocProvider.of<TurboGoBloc>(context).add(TurboGoEndOfLocationChangeEvent(
                  Point(latitude: position.target.latitude, longitude: position.target.longitude)
              ));
            });
          })
        });
      }
    }
  }

  void buildDrivers() {
    OrderModel? last = orderController.last;
    List<DriversOnlineModel> drivers = driversOnlineController.repo.values.where((d) {
      if (last?.driverId != null && ['submitted', 'confirmed', 'active', 'pause', 'wait'].contains(last?.status)) {
        return last!.driverId == d.driverId;
      } else if (last?.tariffId != null && last?.status == 'filled') {
        return last!.tariffId == d.driver['car']['tariffId'];
      }

      return true;
    }).toList();

    int i = 0;
    /*List objects = _objects.toList();
    for (MapObject o in objects) {
      if (o.mapId.value.contains('car_')) {
        if (drivers.where((d) => o.mapId.value == 'car_${d.driverId}').isEmpty) {
          _objects.removeAt(i);
        }
      }
      i++;
    }*/
    _objects = _objects.where((o) {
      if (o.mapId.value.contains('car_')) {
        if (drivers.where((d) => o.mapId.value == 'car_${d.driverId}').isEmpty) {
          return false;
        } else {
          return true;
        }
      }
      return true;
    }).toList();

    for (DriversOnlineModel d in drivers) {
      DriverModel? c = driverController.getById(d.driverId);
      TariffModel? t = tariffController.repo.get(c?.car['tariffId']);

      if (
      c != null
      ) {
        int? i;
        bool exist = false;
        for (MapObject o in _objects) {
          i = i == null ? 0 : i++;
          if (o.mapId.value == 'car_${d.driverId}') {
            exist = true;
            break;
          }
        }

        if (
        d.isOnline() &&
        d.checkAvailability() &&
        t != null && t.mapIcon is String && t.mapIcon!.isNotEmpty
        ) {
          if (exist) {
            _objects[i!] = _driver(d, c, t);
          }
          else {
            _objects.add(_driver(d, c, t));
          }
        } else {
          if (exist && !['start_point', 'end_point'].contains(_objects[i!].mapId.value)) {
            _objects.removeAt(i);
          }
        }
      }
    }
  }

  @override
  void initState() {
    controller = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    animation = Tween<double>(begin: 1, end: 1.08).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOutCubic
        )
    );
    fromReg = widget.fromReg;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (mounted) {
          setState(() {
            buildDrivers();
          });
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _map = ScaleTransition(
      scale: animation,
      child: YandexMap(
          mapType: MapType.vector,
          logoAlignment: const MapAlignment(horizontal: HorizontalAlignment.right, vertical: VerticalAlignment.bottom),
          //poiLimit: 100,
          modelsEnabled: false,
          mode2DEnabled: true,
          mapObjects: _objects,
          onCameraPositionChanged: cameraPositionCallback,
          nightModeEnabled: true,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          zoomGesturesEnabled: _zoomEnabled,
          scrollGesturesEnabled: _scrollEnabled,
          fastTapEnabled: _fastTapEnabled,
          onMapCreated: (YandexMapController ctrl) async {
            mapController = ctrl;

            if (fromReg) {
              clearPoints();
              disableGestures();
              _objects.add(PlacemarkMapObject(
                mapId: const MapObjectId('start_point'),
                point: Point(
                    latitude: orderController.newOrder.from!['coordinates'][0],
                    longitude: orderController.newOrder.from!['coordinates'][1]
                ),
                icon: PlacemarkIcon.single(
                    PlacemarkIconStyle(
                        anchor: const Offset(0.5, 1),
                        scale: 1.2,
                        zIndex: 2,
                        image: BitmapDescriptor.fromAssetImage('lib/assets/images/start_point.png')
                    )
                ),
                opacity: 1,
              ));
              await mapController!.moveCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                      target: Point(
                          latitude: orderController.newOrder.from!['coordinates'][0],
                          longitude: orderController.newOrder.from!['coordinates'][1]
                      ),
                      zoom: _defaultZoomLevel
                  )
              ));
            } else {
              clearObjects();
              enableGestures();
              defaultCameraPosition(context);
            }
            //BlocProvider.of<TurboGoBloc>(context).add(TurboGoHomeEvent());
            /*BlocProvider.of<TurboGoBloc>(context).add(TurboGoEndOfLocationChangeEvent(
          Point(
            latitude: position.target.latitude,
            longitude: position.target.longitude
          )
        ));*/
          }
      ),
    );

    return Stack(children: [
      BlocListener<TurboGoBloc, TurboGoState>(
          listener: (BuildContext ctx, TurboGoState state) async {
            List? fromCoordinates = orderController.newOrder.from?['coordinates'];
            List? whitherCoordinates = orderController.newOrder.whither?['coordinates'];
            bool
            validFromCoordinates =
                fromCoordinates is List && fromCoordinates.length == 2 &&
                    fromCoordinates[0] is double && fromCoordinates[1] is double,
                validWhitherCoordinates =
                    whitherCoordinates is List && whitherCoordinates.length == 2 &&
                        whitherCoordinates[0] is double && whitherCoordinates[1] is double;

            if (_timers['second'] != null) {
              _timers['second']!.cancel();
              _timers['second'] = null;
            }

            if (state is TurboGoLocationHasChangedState/* && state.prevState is! TurboGoTariffsState && state.prevState is! TurboGoDriverState*/) {
              controller.forward();
            } else {
              controller.reverse();
            }

            if (state is TurboGoHomeState) {
              setState(() {
                enableGestures();
                if (state.reset) {
                  clearPoints();
                  defaultCameraPosition(ctx);
                }
              });
            } else if (state is TurboGoPointsState) {
              setState(() {
                enableGestures();
                clearPoints();
                //defaultCameraPosition(ctx);
              });
            } else if (state is TurboGoTariffsState) {
              setState(() {
                disableGestures();

                if (validFromCoordinates) {
                  _objects.add(PlacemarkMapObject(
                    mapId: const MapObjectId('start_point'),
                    point: Point(
                        latitude: fromCoordinates[0],
                        longitude: fromCoordinates[1]
                    ),
                    icon: PlacemarkIcon.single(
                        PlacemarkIconStyle(
                            anchor: const Offset(0.5, 1),
                            scale: 1.2,
                            zIndex: 2,
                            image: BitmapDescriptor.fromAssetImage('lib/assets/images/start_point.png')
                        )
                    ),
                    opacity: 1,
                  ));
                }
                if (validWhitherCoordinates) {
                  _objects.add(PlacemarkMapObject(
                      mapId: const MapObjectId('end_point'),
                      point: Point(
                          latitude: whitherCoordinates[0],
                          longitude: whitherCoordinates[1]
                      ),
                      icon: PlacemarkIcon.single(
                          PlacemarkIconStyle(
                              anchor: const Offset(0.5, 1),
                              scale: 1.2,
                              zIndex: 3,
                              image: BitmapDescriptor.fromAssetImage('lib/assets/images/end_point.png')
                          )
                      ),
                      opacity: 1
                  ));
                }
              });

              if (validFromCoordinates && validWhitherCoordinates) {
                await mapController!.moveCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(
                        target: getCentralPoint([
                          Point(
                              latitude: fromCoordinates[0],
                              longitude: fromCoordinates[1]
                          ),
                          Point(
                              latitude: whitherCoordinates[0],
                              longitude: whitherCoordinates[1]
                          )
                        ]),
                        zoom: getZoomLevel([
                          fromCoordinates,
                          whitherCoordinates
                        ]) - 1
                    )
                ), animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1));
              }
            } else if (state is TurboGoSearchState) {
              setState(() {
                disableGestures();
                /*clearPoints();

                if (validFromCoordinates) {
                  _objects.add(PlacemarkMapObject(
                    mapId: const MapObjectId('start_point'),
                    point: Point(
                        latitude: fromCoordinates[0],
                        longitude: fromCoordinates[1]
                    ),
                    icon: PlacemarkIcon.single(
                        PlacemarkIconStyle(
                            anchor: const Offset(0.5, 1),
                            scale: 1.2,
                            zIndex: 2,
                            image: BitmapDescriptor.fromAssetImage('lib/assets/start_point.png')
                        )
                    ),
                    opacity: 1,
                  ));
                }*/
              });
              if (validFromCoordinates) {
                await mapController!.moveCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(
                        target: Point(
                            latitude: fromCoordinates[0],
                            longitude: fromCoordinates[1]
                        ),
                        zoom: _defaultZoomLevel
                    )
                ));
              }
            } else if (state is TurboGoDriverState) {
              setState(() {
                disableGestures();
                //enableGestures();
              });



              _timers.addAll({
                'second': Timer.periodic(const Duration(milliseconds: 1500), (_) async {
                  DriversOnlineModel? driver = driversOnlineController.getById(orderController.newOrder.driverId!);

                  if (
                  validFromCoordinates &&
                      driver != null && driver.location != null
                  ) {
                    await mapController!.moveCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: getCentralPoint([
                          Point(
                            latitude: fromCoordinates[0],
                            longitude: fromCoordinates[1]
                          ),
                          Point(
                            latitude: driver.location!['coordinates'][0],
                            longitude: driver.location!['coordinates'][1]
                          )
                        ]),
                        zoom: getZoomLevel([
                          fromCoordinates,
                          driver.location!['coordinates']
                        ]) - 2
                      ),
                    ), animation: const MapAnimation());
                  }
                })
              });
            }
          },
          child: _map
      ),
      BlocBuilder<TurboGoBloc, TurboGoState>(
          builder: (BuildContext ctx, TurboGoState state) {
            if (
            (state is TurboGoHomeState) ||
                (state is TurboGoPointsState) ||
                (
                    state is TurboGoLocationHasChangedState// &&
                    //state.prevState is TurboGoPointsState
                )
            ) return picker();
            if (state is TurboGoSearchState) return loader();
            return Container();
          }
      )
    ]);
  }

  PlacemarkMapObject _driver(DriversOnlineModel d, DriverModel c, TariffModel t) {
    return PlacemarkMapObject(
        isVisible: true,
        opacity: 0.6,
        point: Point(
            latitude: (d.location!['coordinates'][0] as num).toDouble(),
            longitude: (d.location!['coordinates'][1] as num).toDouble()
        ),
        mapId: MapObjectId('car_${d.driverId}'),
        icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
                zIndex: 1,
                scale: 0.5,
                rotationType: RotationType.rotate,
                image: BitmapDescriptor.fromBytes(base64Decode(t.mapIcon!))
            )
        ),
        direction: d.direction!
    );
  }

  Widget picker() {
    return IgnorePointer(
      child: Center(
        child: Stack(children: [
          Container(
            transform: Matrix4.translationValues(0.0, -25.0, 0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                BlocBuilder<TurboGoBloc, TurboGoState>(
                  builder: (BuildContext ctx, TurboGoState state) {
                    if (state is TurboGoLocationHasChangedState) {
                      TurboGoState prevState = state.prevState;

                      if (prevState is TurboGoHomeState) {
                        return const Text("Откуда вас забрать?", style: TextStyle(color: Colors.white));
                      }

                      if (prevState is TurboGoPointsState) {
                        return Text(prevState.type == LocationTypes.start ? "Откуда вас забрать?" : "Куда вас отвезти?", style: const TextStyle(color: Colors.white));
                      }
                    }

                    if (state is TurboGoHomeState) {
                      return const Text("Заберем вас отсюда", style: TextStyle(color: Colors.white));
                    }

                    if (state is TurboGoPointsState) {
                      return Text(state.type == LocationTypes.start ? "Заберём вас отсюда" : "Отвезём вас сюда", style: const TextStyle(color: Colors.white));
                    }

                    return Container();
                  },
                ),
                const SizedBox(height: 15),
                BlocBuilder<TurboGoBloc, TurboGoState>(
                    builder: (BuildContext ctx, TurboGoState state) {
                      List<Widget> elements = [
                        Container(
                          decoration: const ShapeDecoration(
                            shadows: [
                              BoxShadow(
                                blurRadius: 4,
                                color: Colors.black38,
                              ),
                            ],
                            shape: CircleBorder(
                              side: BorderSide(
                                width: 4,
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        )
                      ];

                      if (state is TurboGoLocationHasChangedState) {
                        TurboGoState prevState = state.prevState;

                        if (prevState is TurboGoHomeState) {
                          return Column(
                            children: [
                              const ImageIcon(
                                AssetImage('lib/assets/images/start_point.png'),
                                size: 35,
                                color: Colors.white,
                              ), ...elements
                            ],
                          );
                        }

                        if (prevState is TurboGoPointsState) {
                          return Column(
                            children: [
                              ImageIcon(
                                  AssetImage(
                                      (prevState.type == LocationTypes.start)
                                          ? 'lib/assets/images/start_point.png'
                                          : 'lib/assets/images/end_point.png'
                                  ),
                                  size: 35,
                                  color: (prevState.type == LocationTypes.start) ? Colors.white : Colors.redAccent
                              ), ...elements
                            ],
                          );
                        }
                      }

                      if (state is TurboGoHomeState) {
                        return Column(
                          children: [
                            const ImageIcon(
                              AssetImage('lib/assets/images/start_point.png'),
                              size: 35,
                              color: Colors.white,
                            ), ...elements
                          ],
                        );
                      }

                      if (state is TurboGoPointsState) {
                        return Column(
                          children: [
                            ImageIcon(
                                AssetImage(
                                    (state.type == LocationTypes.start)
                                        ? 'lib/assets/images/start_point.png'
                                        : 'lib/assets/images/end_point.png'
                                ),
                                size: 35,
                                color: (state.type == LocationTypes.start) ? Colors.white : Colors.redAccent
                            ), ...elements
                          ],
                        );
                      }

                      return Container();
                    }
                ),
              ],
            ),
          )
        ],),
      ),
    );
  }

  Widget loader() {
    return IgnorePointer(
      child: Stack(
        children: [
          BlocBuilder<TurboGoBloc, TurboGoState>(
            builder: (ctx, state) {
              return const SpinKitRipple(
                color: Colors.white38,
                size: 250,
                borderWidth: 15,
              );
            },
          )
        ],
      ),
    );
  }
}

/*class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);

    Paint p = Paint()
    ..color = Colors.red
    ..strokeWidth = 5
    ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, size.width / 4, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}*/