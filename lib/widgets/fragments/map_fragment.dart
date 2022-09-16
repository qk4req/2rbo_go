import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:turbo_go/controllers/clients_online_controller.dart';
import 'package:turbo_go/controllers/order_controller.dart';
import 'package:turbo_go/models/clients_online_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:keyboard_service/keyboard_service.dart';

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

class _MapFragmentState extends State<MapFragment>{
  static final ClientsOnlineController _clientsOnline = TurboGoBloc.clientsOnlineController;
  final DriverController _driver = TurboGoBloc.driverController;
  final DriversOnlineController _driversOnline = TurboGoBloc.driversOnlineController;
  final OrderController _order = TurboGoBloc.orderController;
  static YandexMapController? mapController;
  static ClientsOnlineModel? clientsOnlineModel = TurboGoBloc.clientsOnlineController.clientsOnlineModel;
  late Widget _map;
  static final List<MapObject> _objects = [];
  static bool _zoomEnabled = true;
  static bool _scrollEnabled = true;
  static bool _fastTapEnabled = true;
  static const double _defaultZoomLevel = 16.5;
  Timer? _timer;
  static bool triggeredCameraPosition = false;
  late bool fromReg;

  static void enableGestures() {
    _zoomEnabled = true;
    _scrollEnabled = true;
    _fastTapEnabled = true;
  }

  static void disableGestures() {
    _zoomEnabled = false;
    _scrollEnabled = false;
    _fastTapEnabled = false;
  }

  static void clearObjects() {
    _objects.clear();
  }

  static void clearPoints () {
    _objects.removeWhere((MapObject o) {
      return o.mapId.value.contains('point');
    });
  }

  static void hideAllDrivers () {
    //_objects = _objects.map<MapObject>((MapObject o) {

    //}).toList();
  }

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
      _clientsOnline.repo.watch().listen((event) {
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
      reason.name == 'gestures'// ||
      //(reason.name == 'application' && position.target.latitude == )
    ) {
      BlocProvider.of<TurboGoBloc>(context).add(TurboGoStartOfLocationChangeEvent());
      _timer?.cancel();
      if (finished) {
        _timer = Timer(const Duration(milliseconds: 500), () {
          mapController!.getCameraPosition().then((CameraPosition position) {
            BlocProvider.of<TurboGoBloc>(context).add(TurboGoEndOfLocationChangeEvent(
                Point(latitude: position.target.latitude, longitude: position.target.longitude)
            ));
          });
        });
      }
    }
  }

  void driverOnMap(DriversOnlineModel d) {
    DriverModel? c = _driver.getById(d.driverId);
    if (c != null) {
      int? index;
      bool exist = false;
      for (MapObject o in _objects) {
        index = index == null ? 0 : index++;
        if (o.mapId.value == 'car_${d.driverId}') {
          exist = true;
          break;
        }
      }

      if (
        d.isOnline() &&
        d.checkAvailability()
      ) {
        if (exist) {
          _objects[index!] = placemark(d, c);
        }
        else {
          _objects.add(placemark(d, c));
        }
      } else {
        if (exist) {
          _objects.removeAt(index!);
        }
      }
    }
  }

  @override
  void initState() {
    /*driversOnlineController.repo.watch().listen((event) {
      DriversOnlineModel d = event.value;

    });

    if (driversOnlineController.repo.isNotEmpty) {
      for (DriversOnlineModel d in driversOnlineController.repo.values) {
        driverOnMap(d);
      }
    }*/
    fromReg = widget.fromReg;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer.periodic(const Duration(milliseconds: 1000), (_) {
        if (mounted) {
          setState(() {
            for (DriversOnlineModel d in _driversOnline.repo.values) {
              driverOnMap(d);
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    _map = YandexMap(
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
                  latitude: _order.last!.from!['coordinates'][0],
                  longitude: _order.last!.from!['coordinates'][1]
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
                        latitude: _order.last!.from!['coordinates'][0],
                        longitude: _order.last!.from!['coordinates'][1]
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
    );

    return Stack(children: [
      BlocListener<TurboGoBloc, TurboGoState>(
          listener: (BuildContext ctx, TurboGoState state) async {
            List? fromCoordinates = _order.newOrder.from?['coordinates'];
            List? whitherCoordinates = _order.newOrder.whither?['coordinates'];
            bool
            validFromCoordinates =
                fromCoordinates is List && fromCoordinates.length == 2 &&
                    fromCoordinates[0] is double && fromCoordinates[1] is double,
                validWhitherCoordinates =
                    whitherCoordinates is List && whitherCoordinates.length == 2 &&
                        whitherCoordinates[0] is double && whitherCoordinates[1] is double;

            if (state is TurboGoHomeState) {
              setState(() {
                enableGestures();
                if (state.reset) {
                  clearPoints();
                  defaultCameraPosition(ctx);
                }
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
                clearPoints();

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
                }
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
              });

              DriversOnlineModel? driver = _driversOnline.getById(_order.last!.driverId!);
              if (
              validFromCoordinates &&
                  driver != null && driver.location != null
              ) {
                //setState(() {
                //  disableGestures();
                //});

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
                        ]) - 1
                    )
                ));
              }
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

  PlacemarkMapObject placemark(DriversOnlineModel d, DriverModel c) {
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
                image: BitmapDescriptor.fromBytes(base64Decode(c.car['tariff']['mapIcon']))
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
                      if (state is TurboGoLocationHasChangedState) {
                        TurboGoState prevState = state.prevState;

                        if (prevState is TurboGoHomeState) {
                          return const ImageIcon(
                            AssetImage('lib/assets/images/start_point.png'),
                            size: 35,
                            color: Colors.white,
                          );
                        }

                        if (prevState is TurboGoPointsState) {
                          return ImageIcon(
                            AssetImage(
                              (prevState.type == LocationTypes.start)
                                ? 'lib/assets/images/start_point.png'
                                : 'lib/assets/images/end_point.png'
                            ),
                            size: 35,
                            color: (prevState.type == LocationTypes.start) ? Colors.white : Colors.redAccent
                          );
                        }
                      }

                      if (state is TurboGoHomeState) {
                        return const ImageIcon(
                          AssetImage('lib/assets/images/start_point.png'),
                          size: 35,
                          color: Colors.white,
                        );
                      }

                      if (state is TurboGoPointsState) {
                        return ImageIcon(
                          AssetImage(
                            (state.type == LocationTypes.start)
                              ? 'lib/assets/images/start_point.png'
                              : 'lib/assets/images/end_point.png'
                          ),
                          size: 35,
                          color: (state.type == LocationTypes.start) ? Colors.white : Colors.redAccent
                        );
                      }

                      return Container();
                    }
                ),
                //const Icon(Icons.place, size: 35, color: Colors.white38,),
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