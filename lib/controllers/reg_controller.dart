import 'package:flutter/foundation.dart';
import 'package:turbo_go/models/client_model.dart';
import '/bloc/turbo_go_bloc.dart';

class RegController extends ChangeNotifier {
  final ClientModel _client = TurboGoBloc.clientController.clientModel;
  Map? response;
  Function(Map driver)? onSuccess;

  RegController () {
    TurboGoBloc.usersSocket.on('clients.reg', (data) {
      if (!data['success']) {
        response = data;
        notifyListeners();
      } else {
        if (onSuccess != null) {
          onSuccess!(data['payload']);
        }
      }
    });
  }

  void reg (String phoneNumber, [Function(Map driver)? onSuccess]) {
    if (TurboGoBloc.usersSocket.connected) {
      this.onSuccess = onSuccess;
      Map newClient = {
        'uuid': _client.uuid,
        'phoneNumber': phoneNumber,
        'createdAt': _client.createdAt,
        'updatedAt': _client.updatedAt
      };
      TurboGoBloc.usersSocket.emit('clients.reg', [newClient]);
    } else {
      response = null;
      notifyListeners();
    }
  }
}