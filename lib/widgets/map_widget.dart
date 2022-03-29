import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turbo_go/models/driver_model.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';
import 'package:keyboard_service/keyboard_service.dart';

import '/bloc/turbo_go_bloc.dart';
import '/bloc/turbo_go_event.dart';
import '/bloc/turbo_go_state.dart';
import '/models/client_model.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget>{
  static ClientModel? model = TurboGoBloc.clientController.clientModel;
  Timer? _timer;
  late Widget map;
  static List<MapObject> cars = [];
  static CameraPositionCallback? onCameraPositionChanged;

  @override
  void initState() {
    TurboGoBloc.driverController.repo.watch().listen((event) {
      DriverModel d = event.value;
      //if (d.status == 'free') {
        setState(() {
          cars.add(Placemark(
              isVisible: d.status == 'free',
              opacity: 1,
              point: Point(
                  latitude: (d.location['coordinates'][0] as num).toDouble(),
                  longitude: (d.location['coordinates'][1] as num).toDouble()
              ),
              mapId: MapObjectId('car_${d.id}'),
              icon: PlacemarkIcon.single(
                  PlacemarkIconStyle(
                      zIndex: 1,
                      scale: 0.5,
                      rotationType: RotationType.rotate,
                      image: BitmapDescriptor.fromBytes(base64Decode(d.car['tariff']['mapIcon']))
                  )
              ),
              direction: d.direction
          ));
        });
      //}
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    map = BlocListener<TurboGoBloc, TurboGoState>(
        listener: (BuildContext ctx, TurboGoState state) {
          /*switch (state.runtimeType) {
            case TurboGoPointsState:
              onCameraPositionChanged = defaultCameraPositionCallback;
              break;
            default:
              onCameraPositionChanged = null;
              break;
          }*/
        },
        child: YandexMap(
            mapObjects: cars,
            onCameraPositionChanged: defaultCameraPositionCallback,//onCameraPositionChanged ?? defaultCameraPositionCallback,
            nightModeEnabled: true,
            rotateGesturesEnabled: false,
            onMapCreated: (YandexMapController ctrl) {
              TurboGoBloc.mapController = ctrl;
              CameraPosition position = CameraPosition(
                  zoom: model?.location == null ? 3 : 16.5,
                  target: Point(
                      latitude: model?.location?['coordinates'][0] ?? 61.698394,
                      longitude: model?.location?['coordinates'][1] ?? 99.502091
                  )
              );
              ctrl.moveCamera(
                  CameraUpdate.newCameraPosition(
                      position
                  ),
                  animation: const MapAnimation(
                      type: MapAnimationType.smooth,
                      duration: 2
                  )
              );
              BlocProvider.of<TurboGoBloc>(context).add(TurboGoEndOfLocationChangeEvent(
                  Point(
                      latitude: position.target.latitude,
                      longitude: position.target.longitude
                  )
              ));
            }
        )
    );
    return Stack(children: [
      map,
      picker()
    ],);
  }

  void defaultCameraPositionCallback (position, CameraUpdateReason reason, finished) {
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

  Widget picker() {
    return IgnorePointer(
      child: Center(
        child: Container(
          transform: Matrix4.translationValues(0.0, -25.0, 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              BlocBuilder<TurboGoBloc, TurboGoState>(
                builder: (BuildContext ctx, TurboGoState state) {
                  if (state is TurboGoLocationHasChangedState) {
                    TurboGoState prevState = state.prevState;
                    if (prevState is TurboGoPointsState) {
                      return Text(prevState.type == LocationType.start ? "Откуда вас забрать?" : "Куда вас отвезти?", style: const TextStyle(color: Colors.white));
                    }
                  }
                  if (state is TurboGoPointsState) {
                    return Text(state.type == LocationType.start ? "Заберем вас отсюда" : "Отвезём вас сюда", style: const TextStyle(color: Colors.white));
                  }
                  return const Text("");
                },
              ),
              const SizedBox(height: 15),
              const Icon(Icons.place, size: 35, color: Colors.white38,),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}