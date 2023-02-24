import 'dart:async';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart';
//import 'package:turbo_go/controllers/clients_online_controller.dart';
import 'package:uuid/uuid.dart';

import '/bloc/turbo_go_bloc.dart';
import '/controllers/timestamp_controller.dart';
import '/models/client_model.dart';

class ClientController {
  final TimestampController _timestamp = TurboGoBloc.timestampController;
  //final ClientsOnlineController _clientsOnline = TurboGoBloc.clientsOnlineController;
  final Socket _socket = TurboGoBloc.adminsSocket;
  //String? _deviceId;
  late ClientModel clientModel;
  Box repo = Hive.box('client');

  ClientController() {
    //determineDeviceId();
    //if (repo.isNotEmpty) {
      clientModel = ClientModel(
        repo.get('uuid') ?? const Uuid().v4(),
        repo.get('lastName'),
        repo.get('firstName'),
        repo.get('middleName'),
        repo.get('phoneNumber'),
        repo.get('password'),
        repo.get('createdAt') ?? _timestamp.create().toTimestamp(),
        repo.get('updatedAt') ?? _timestamp.create().toTimestamp(),
      );
    //}
    repo.putAll({
      'uuid': clientModel.uuid,
      'lastName': clientModel.lastName,
      'firstName': clientModel.firstName,
      'middleName': clientModel.middleName,
      'phoneNumber': clientModel.phoneNumber,
      'password': clientModel.password,
      'createdAt': clientModel.createdAt,
      'updatedAt': clientModel.updatedAt
    });
  }

  /*determineDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    _deviceId = androidInfo.androidId;
  }*/

  bool compare(Map client) {
    return client['updatedAt'] == clientModel.updatedAt;
  }

  void update(Map client, [bool sync = true, FutureOr<dynamic> Function()? onSaved]) {
    if (client.isNotEmpty) {
      clientModel =
          ClientModel(
              client['uuid'] ?? clientModel.uuid,
              client['lastName'] ?? clientModel.lastName,
              client['firstName'] ?? clientModel.firstName,
              client['middleName'] ?? clientModel.middleName,
              client['phoneNumber'] ?? clientModel.phoneNumber,
              client['password'] ?? clientModel.password,
              client['createdAt'] ?? clientModel.createdAt,
              client['updatedAt'] ?? _timestamp.create().toTimestamp()
          );

      repo.putAll(client).then((_) async {
        if (onSaved != null) {
          await onSaved();
        }
      });

      if (sync) {
        _socket.emit('clients.update', [
          {
            'lastName': clientModel.lastName,
            'firstName': clientModel.firstName,
            'middleName': clientModel.middleName,
            'phoneNumber': clientModel.phoneNumber,
            'password': clientModel.password,
            'createdAt': clientModel.createdAt,
            'updatedAt': clientModel.updatedAt
          },
          {
            'uuid': clientModel.uuid,
          }
        ]);
      }
    }
  }

  void create([bool sync = true]) {
    if (sync) {
      _socket.emit('clients.create', {
        'uuid': clientModel.uuid,
        'lastName': clientModel.lastName,
        'firstName': clientModel.firstName,
        'middleName': clientModel.middleName,
        'phoneNumber': clientModel.phoneNumber,
        'password': clientModel.password,
        'createdAt': clientModel.createdAt,
        'updatedAt': clientModel.updatedAt
      });
    }
  }
}