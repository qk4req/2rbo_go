import 'dart:async';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:turbo_go/bloc/turbo_go_bloc.dart';
import 'package:turbo_go/controllers/timestamp_controller.dart';

import '/models/clients_online_model.dart';

class ClientsOnlineController {
  final Socket _socket = TurboGoBloc.socket;
  final TimestampController _timestamp = TurboGoBloc.timestampController!;
  ClientsOnlineModel? clientsOnlineModel;
  Box<ClientsOnlineModel> repo = Hive.box('clients_online');

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
        client['updatedAt'] ?? _timestamp.create().toString()
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