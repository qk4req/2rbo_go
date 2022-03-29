import '/controllers/client_controller.dart';

class ClientModel {
  String deviceId;
  int? id;
  String? lastName;
  String? firstName;
  String? middleName;
  String? phoneNumber;
  String? password;
  Map? location;
  String? createdAt;
  String? updatedAt;

  ClientModel(
      this.deviceId,
      [
        this.id,
        this.lastName,
        this.firstName,
        this.middleName,
        this.phoneNumber,
        this.password,
        this.location,
        this.createdAt,
        this.updatedAt
      ]
  );
}