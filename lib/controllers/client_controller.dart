import 'dart:async';
import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '/bloc/turbo_go_bloc.dart';
import '/models/client_model.dart';

class ClientController {
  final Socket _socket = TurboGoBloc.socket;
  ClientModel? clientModel;
  Box repo = Hive.box('client');

  ClientController() {
    if (repo.isNotEmpty) {
      clientModel = ClientModel(
        repo.get('deviceId'),
        repo.get('id'),
        repo.get('lastName'),
        repo.get('firstName'),
        repo.get('middleName'),
        repo.get('phoneNumber'),
        repo.get('password'),
        repo.get('location'),
        repo.get('createdAt'),
        repo.get('updatedAt'),
      );
    }

    Geolocator.checkPermission().then((LocationPermission value) async {
      switch (value.name) {
        case 'denied':
        case 'deniedForever':
          await Geolocator.requestPermission();
          break;
        case 'always':
        case 'whileInUse':
          const LocationSettings locationSettings = LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          );
          StreamSubscription<Position> positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position? position) {
            _socket.emit(
              'clients.update',
              {
                'type': 'Point',
                'coordinates': [position?.latitude, position?.longitude]
              }
            );
          });
          break;
      }
    });
  }

  bool compare(Map client) {
    return client['updatedAt'] == clientModel?.updatedAt;
  }

  void update(Map client, [FutureOr<dynamic> Function()? onSaved]) {
    if (client.isNotEmpty) {
      clientModel =
          ClientModel(
            clientModel?.deviceId ?? client['deviceId'],
            clientModel?.id ?? client['id'],
            clientModel?.lastName ?? client['lastName'],
            clientModel?.firstName ?? client['firstName'],
            clientModel?.middleName ?? client['middleName'],
            clientModel?.phoneNumber ?? client['phoneNumber'],
            clientModel?.password ?? client['password'],
            clientModel?.location ?? client['location'],
            clientModel?.updatedAt ?? client['updatedAt'],
            clientModel?.createdAt ?? client['createdAt']
          );

      repo.putAll(client).then((_) async {
        if (onSaved != null) {
          await onSaved();
        }
      });
    }
  }
}