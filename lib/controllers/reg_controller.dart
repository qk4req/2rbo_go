import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:turbo_go/models/client_model.dart';
import '../bloc/turbo_go_bloc.dart';

class RegController extends ChangeNotifier {
  final ClientModel _client = TurboGoBloc.clientController.clientModel;
  Socket socket = io(
      '${TurboGoBloc.apiUrl}/users',
      OptionBuilder()
          .setTransports(['websocket'])
      //.disableAutoConnect()
          .enableReconnection()
          .setTimeout(3000)
          .build()
  );
  Map? response;
  Function(Map driver)? onSuccess;

  RegController() {
    socket.connect();
    socket.onConnect((_) {
      if (!socket.hasListeners('clients.reg')) {
        socket.on('clients.reg', (data) {
          if (!data['success']) {
            response = data;
            notifyListeners();
          } else {
            print(12333);
            if (onSuccess != null) {
              onSuccess!(data['payload']);
            }
          }
        });
      }
    });
  }

  void reg(String phoneNumber, [Function(Map driver)? onSuccess]) {
    if (socket.connected) {
      this.onSuccess = onSuccess;
      Map newClient = {
        'uuid': _client.uuid,
        'phoneNumber': phoneNumber,
        'createdAt': _client.createdAt,
        'updatedAt': _client.updatedAt
      };
      socket.emit('clients.reg', [newClient]);
    } else {
      response = null;
      notifyListeners();
    }
  }
}