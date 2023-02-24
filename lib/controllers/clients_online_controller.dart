import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:turbo_go/bloc/turbo_go_bloc.dart';
import 'package:turbo_go/controllers/client_controller.dart';
import 'package:turbo_go/controllers/timestamp_controller.dart';
import '/models/clients_online_model.dart';



class GeoFilters {
  static num minDistance = 10;//мин. дистанция >= 10м
  static num maxAccuracy = 150;
  static num maxSpeed = 41.6667;//макс. скорость<=41.6667м/с (150км/ч)
  static num maxAcceleration = 3;//макс. ускорение<=3м/c
  static const int _maxPositions = 1000;
  static const double _minAccuracy = 1.0;
  //static const double _q = 3.0;
  static late int _timeStampMilliseconds;
  static late double _lat;
  static late double _lng;
  static double _variance = -1;
  static List<Position> positions = [];

  static num calculateSpeed (Position first, Position second) {
    if (first.timestamp == null || second.timestamp == null) return 0;

    num s = SphericalUtil.computeDistanceBetween(LatLng(first.latitude, first.longitude), LatLng(second.latitude, second.longitude));// / 1000;
    int t = ((first.timestamp!.millisecondsSinceEpoch - second.timestamp!.millisecondsSinceEpoch) ~/ 1000).abs();
    return (s/t);
  }

  static bool process (Position position) {
    if (positions.length > _maxPositions) {
      positions.removeAt(0);
    }
    bool filter =
        distance(position) &&
            accuracy(position) &&
            speed(position);// &&
            //acceleration(position);
    if (filter) {
      kalman(position);
    }

    return filter;
  }

  static bool distance(Position position) {
    if (positions.isEmpty) return (true);
    num s = SphericalUtil.computeDistanceBetween(LatLng(position.latitude, position.longitude), LatLng(positions.last.latitude, positions.last.longitude));
    return s >= minDistance;
  }

  static bool accuracy(Position position) {
    return position.accuracy <= maxAccuracy;
  }

  static bool speed (Position position) {
    if (positions.isEmpty) return(true);
    if (position.timestamp != null) {
      return (calculateSpeed(position, positions.last) <= maxSpeed);
    } else {
      return false;
    }
  }

  static bool acceleration (Position position) {
    if (positions.length < 2) return (true);

    num v0 = calculateSpeed(positions.elementAt(positions.length-2), positions.last);
    num v1 = calculateSpeed(positions.last, position);
    num dt = (position.timestamp!.millisecondsSinceEpoch - positions.last.timestamp!.millisecondsSinceEpoch) ~/ 1000;
    return (((v0 - v1 / dt)).abs() <= maxAcceleration);
  }

  static void kalman(Position position) {
    double accuracyMeasurement = position.accuracy;
    int timeStampMillisecondsMeasurement = position.timestamp!.millisecondsSinceEpoch;
    double latMeasurement = position.latitude;
    double lngMeasurement = position.longitude;

    if (accuracyMeasurement < _minAccuracy) {
      accuracyMeasurement = _minAccuracy;
    }
    if (_variance < 0) {
      _timeStampMilliseconds = timeStampMillisecondsMeasurement;
      _lat = latMeasurement;
      _lng = lngMeasurement;
      _variance = accuracyMeasurement * accuracyMeasurement;
    } else {
      int timeIncMilliseconds = timeStampMillisecondsMeasurement - _timeStampMilliseconds;
      if (timeIncMilliseconds > 0) {
        _variance += timeIncMilliseconds * maxSpeed * maxSpeed / 1000;
        _timeStampMilliseconds = timeStampMillisecondsMeasurement;
      }

      double K = _variance / (_variance + accuracyMeasurement * accuracyMeasurement);
      _lat += K * (latMeasurement - _lat);
      _lng += K * (lngMeasurement - _lng);
      _variance = (1 - K) * _variance;
    }

    positions.add(Position(
        longitude: _lng,
        latitude: _lat,
        timestamp: position.timestamp,
        accuracy: position.accuracy,
        altitude: position.altitude,
        heading: position.heading,
        speed: position.speed,
        speedAccuracy: position.speedAccuracy
    ));
  }
}

class ClientsOnlineController {
  final Socket _socket = TurboGoBloc.adminsSocket;
  final TimestampController _timestamp = TurboGoBloc.timestampController;
  //final ClientController _clients = TurboGoBloc.clientController;
  ClientsOnlineModel? clientsOnlineModel;
  Box<ClientsOnlineModel> repo = Hive.box('clients_online');
  final LocationSettings _locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0
  );
  StreamSubscription<Position>? _positionStream;

  void _unregisterPositionStream () {
    _positionStream!.cancel();
    _positionStream = null;
  }

  void _registerPositionStream () {
    if (_positionStream != null) {
      _unregisterPositionStream();
    }

    _positionStream = Geolocator.getPositionStream(locationSettings: _locationSettings).listen((Position position) {
      bool filter = GeoFilters.process(position);
      if (clientsOnlineModel != null && filter) {
        update(
            {
              //'clientId': _clients.clientModel.uuid,
              'clientId': clientsOnlineModel?.clientId,
              'location': {
                'type': 'Point',
                'coordinates': [GeoFilters.positions.last.latitude, GeoFilters.positions.last.longitude]
              },
            },
            false
        );
      }
    });
  }

  ClientsOnlineController () {
    Geolocator.checkPermission().then((permission) async {
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }
    });

    Geolocator.isLocationServiceEnabled().then((bool enabled) {
      if (enabled) _registerPositionStream();
    });

    Geolocator.getServiceStatusStream().listen(
        (ServiceStatus status) {
          if (status == ServiceStatus.enabled && _positionStream == null) {
            _registerPositionStream();
          } else {
            _unregisterPositionStream();
          }
        }
    );

    /*FlutterCompass.events?.listen((CompassEvent event) {
      update(
          {
            'clientId': _clients.clientModel.uuid,
            'direction': event.heading
          },
          false
      );
    });*/
    Timer.periodic(const Duration(milliseconds: 1000), (_) {
      if (clientsOnlineModel != null) {
        update({
          //'clientId': _clients.clientModel.uuid
          'clientId': clientsOnlineModel?.clientId
        });
      }
    });
  }

  bool compare(Map client) {
    return client['updatedAt'] == repo.get(client['clientId'])?.updatedAt;
  }

  bool contains(Map client) {
    return repo.containsKey(client['clientId']);
  }

  void update(Map client, [bool sync = true, FutureOr<dynamic> Function()? onSaved]) {
    //if (contains(client)) {
    ClientsOnlineModel c = repo.get(client['clientId'])!;

    c.location = client['location'] ?? c.location;
    c.direction = client['direction'] != null ? (client['direction'] as num).toDouble() : c.direction;
    c.updatedAt = client['updatedAt'] ?? c.updatedAt;
    clientsOnlineModel = c;

    repo.put(c.clientId, c).then((_) async {
      if (onSaved != null) {
        await onSaved();
      }
    });
    //}
    if (sync) {
      _socket.emit('clientsOnline.update', [
        {
          'location': c.location,
          'direction': c.direction,
          'updatedAt': c.updatedAt
        },
        {
          'clientId': c.clientId
        }
      ]);
    }
  }

  void create(Map client, [bool sync = true]) {
    //if (!contains(driver)) {
    ClientsOnlineModel c = ClientsOnlineModel(
        client['clientId'],
        client['location'],
        client['direction'] != null ? (client['direction'] as num).toDouble() : null,
        client['updatedAt'] ?? _timestamp.create().toTimestamp()
    );

    repo.put(c.clientId, c);
    clientsOnlineModel = c;
    //}

    if (sync) {
      _socket.emit('clientsOnline.create', {
        'clientId': c.clientId,
        'location': c.location,
        'direction': c.direction,
        'updatedAt': c.updatedAt
      });
    }
  }

  /*ClientsOnlineModel? getById(int id) {
    return repo.get(id);
  }*/
}