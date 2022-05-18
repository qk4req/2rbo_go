import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:turbo_go/controllers/driver_controller.dart';
import 'package:turbo_go/controllers/drivers_online_controller.dart';
import 'package:turbo_go/models/driver_model.dart';
import 'package:turbo_go/models/drivers_online_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:keyboard_service/keyboard_service.dart';

import '../controllers/timestamp_controller.dart';
import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_event.dart';
import '/bloc/turbo_go_state.dart';
import '/models/client_model.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

double getBoundsZoomLevel(BoundingBox bounds, Size mapDimensions) {
  var worldDimension = const Size(1024, 1024);

  double latRad(lat) {
    var sinValue = sin(lat * pi / 180);
    var radX2 = log((1 + sinValue) / (1 - sinValue)) / 2;
    return max(min(radX2, pi), -pi) / 2;
  }

  double zoom(mapPx, worldPx, fraction) {
    return (log(mapPx / worldPx / fraction) / ln2).floorToDouble();
  }

  var ne = bounds.northEast;
  var sw = bounds.southWest;

  var latFraction = (latRad(ne.latitude) - latRad(sw.latitude)) / pi;

  var lngDiff = ne.longitude - sw.longitude;
  var lngFraction = ((lngDiff < 0) ? (lngDiff + 360) : lngDiff) / 360;

  var latZoom = zoom(mapDimensions.height, worldDimension.height, latFraction);
  var lngZoom = zoom(mapDimensions.width, worldDimension.width, lngFraction);

  if (latZoom < 0) return lngZoom;
  if (lngZoom < 0) return latZoom;

  return min(latZoom, lngZoom);
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

class _MapWidgetState extends State<MapWidget>{
  final DriverController _driver = TurboGoBloc.driverController;
  final DriversOnlineController _driversOnline = TurboGoBloc.driversOnlineController;
  final TimestampController _timestamp = TurboGoBloc.timestampController!;
  static ClientModel? clientModel = TurboGoBloc.clientController.clientModel;
  static YandexMapController? mapController;
  Timer? _timer;
  late Widget _map;
  static final List<MapObject> _objects = [];
  static bool _zoomEnabled = true;
  static bool _scrollEnabled = true;
  static bool _fastTapEnabled = true;
  static const double _defaultZoomLevel = 16.5;

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

  void defaultCameraPositionCallback (CameraPosition position, CameraUpdateReason reason, finished) {
    KeyboardService.dismiss();
    if (reason.name == 'gestures') {
      BlocProvider.of<TurboGoBloc>(context).add(TurboGoStartOfLocationChangeEvent());
      _timer?.cancel();
      if (finished) {
        _timer = Timer(const Duration(milliseconds: 500), () {
          TurboGoBloc.mapController?.getCameraPosition().then((CameraPosition position) {
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
        d.location != null && d.direction != null &&
        DateTime.parse(d.updatedAt).isAfter(_timestamp.create().subtract(const Duration(seconds: 30))) &&
        (c.balance > (c.car['tariff']['baseCost'] * c.car['tariff']['commission'])) &&
        c.status == 'active'
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
    Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        for (DriversOnlineModel d in _driversOnline.repo.values) {
          driverOnMap(d);
        }
      });
    });
    /*driversOnlineController.repo.watch().listen((event) {
      DriversOnlineModel d = event.value;

    });

    if (driversOnlineController.repo.isNotEmpty) {
      for (DriversOnlineModel d in driversOnlineController.repo.values) {
        driverOnMap(d);
      }
    }*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _map = YandexMap(
        mapObjects: _objects,
        onCameraPositionChanged: defaultCameraPositionCallback,
        nightModeEnabled: true,
        rotateGesturesEnabled: false,
        tiltGesturesEnabled: false,
        zoomGesturesEnabled: _zoomEnabled,
        scrollGesturesEnabled: _scrollEnabled,
        fastTapEnabled: _fastTapEnabled,
        onMapCreated: (YandexMapController ctrl) {
          mapController = ctrl;
          TurboGoBloc.mapController = ctrl;


          CameraPosition position = CameraPosition(
              zoom: clientModel?.location == null ? 3 : _defaultZoomLevel,
              target: Point(
                  latitude: clientModel?.location?['coordinates'][0] ?? 61.698394,
                  longitude: clientModel?.location?['coordinates'][1] ?? 99.502091
              )
          );
          ctrl.moveCamera(
            CameraUpdate.newCameraPosition(
                position
            )
          );
          BlocProvider.of<TurboGoBloc>(context).add(TurboGoEndOfLocationChangeEvent(
              Point(
                  latitude: position.target.latitude,
                  longitude: position.target.longitude
              )
          ));
        }
    );

    return Stack(children: [
      BlocListener<TurboGoBloc, TurboGoState>(
          listener: (BuildContext ctx, TurboGoState state) async {
            switch (state.runtimeType) {
              case TurboGoHomeState:
                setState(() {
                  enableGestures();
                });
              break;
              case TurboGoTariffsState:
                setState(() {
                  disableGestures();
                  if (TurboGoBloc.orderController.newOrder.from != null) {
                    _objects.add(Placemark(
                        mapId: const MapObjectId('start_point'),
                        point: Point(
                            latitude: TurboGoBloc.orderController.newOrder.from!['coordinates'][0],
                            longitude: TurboGoBloc.orderController.newOrder.from!['coordinates'][1]
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
                  if (TurboGoBloc.orderController.newOrder.whither != null) {
                    _objects.add(Placemark(
                        mapId: const MapObjectId('end_point'),
                        point: Point(
                            latitude: TurboGoBloc.orderController.newOrder.whither!['coordinates'][0],
                            longitude: TurboGoBloc.orderController.newOrder.whither!['coordinates'][1]
                        ),
                        icon: PlacemarkIcon.single(
                          PlacemarkIconStyle(
                              anchor: const Offset(0.5, 1),
                              scale: 1.2,
                              zIndex: 3,
                            image: BitmapDescriptor.fromAssetImage('lib/assets/end_point.png')
                          )
                        ),
                        opacity: 1
                    ));
                  }
                });

                await mapController?.moveCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: getCentralPoint([
                      Point(
                        latitude: TurboGoBloc.orderController.newOrder.from!['coordinates'][0],
                        longitude: TurboGoBloc.orderController.newOrder.from!['coordinates'][1]
                      ),
                      Point(
                        latitude: TurboGoBloc.orderController.newOrder.whither!['coordinates'][0],
                        longitude: TurboGoBloc.orderController.newOrder.whither!['coordinates'][1]
                      )
                    ]),
                    zoom: getZoomLevel([
                      TurboGoBloc.orderController.newOrder.from!['coordinates'],
                      TurboGoBloc.orderController.newOrder.whither!['coordinates']
                    ]) - 1
                  )
                ), animation: const MapAnimation(type: MapAnimationType.smooth, duration: 1));
              break;
              case TurboGoSearchState:
                setState(() {
                  disableGestures();
                });
                await mapController?.moveCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(
                        target: Point(
                            latitude: TurboGoBloc.orderController.newOrder.from!['coordinates'][0],
                            longitude: TurboGoBloc.orderController.newOrder.from!['coordinates'][1]
                        ),
                        zoom: _defaultZoomLevel
                    )
                ));
              break;
              case TurboGoDriverState:
                setState(() {
                  disableGestures();
                });
                /*await mapController?.moveCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(
                        target: getCentralPoint([
                          Point(
                              latitude: TurboGoBloc.orderController.newOrder.from!['coordinates'][0],
                              longitude: TurboGoBloc.orderController.newOrder.from!['coordinates'][1]
                          ),
                          
                        ]),
                        zoom: _defaultZoomLevel
                    )
                ));*/
                break;
              default:
              //onCameraPositionChanged = null;
              break;
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
    ],);
  }

  Placemark placemark(DriversOnlineModel d, DriverModel c) {
    return Placemark(
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
                        return Text(prevState.type == LocationType.start ? "Откуда вас забрать?" : "Куда вас отвезти?", style: const TextStyle(color: Colors.white));
                      }
                    }

                    if (state is TurboGoHomeState) {
                      return const Text("Заберем вас отсюда", style: TextStyle(color: Colors.white));
                    }

                    if (state is TurboGoPointsState) {
                      return Text(state.type == LocationType.start ? "Заберём вас отсюда" : "Отвезём вас сюда", style: const TextStyle(color: Colors.white));
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
                            AssetImage('lib/assets/start_point.png'),
                            size: 35,
                            color: Colors.white,
                          );
                        }

                        if (prevState is TurboGoPointsState) {
                          return ImageIcon(
                            AssetImage(
                              (prevState.type == LocationType.start)
                                ? 'lib/assets/start_point.png'
                                : 'lib/assets/end_point.png'
                            ),
                            size: 35,
                            color: (prevState.type == LocationType.start) ? Colors.white : Colors.redAccent
                          );
                        }
                      }

                      if (state is TurboGoHomeState) {
                        return const ImageIcon(
                          AssetImage('lib/assets/start_point.png'),
                          size: 35,
                          color: Colors.white,
                        );
                      }

                      if (state is TurboGoPointsState) {
                        return ImageIcon(
                          AssetImage(
                            (state.type == LocationType.start)
                              ? 'lib/assets/start_point.png'
                              : 'lib/assets/end_point.png'
                          ),
                          size: 35,
                          color: (state.type == LocationType.start) ? Colors.white : Colors.redAccent
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