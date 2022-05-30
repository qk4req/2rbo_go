import '/controllers/client_controller.dart';

class ClientModel {
  String uuid;
  String? lastName;
  String? firstName;
  String? middleName;
  String? phoneNumber;
  String? password;
  String? createdAt;
  String? updatedAt;

  ClientModel(
      this.uuid,
      [
        this.lastName,
        this.firstName,
        this.middleName,
        this.phoneNumber,
        this.password,
        this.createdAt,
        this.updatedAt
      ]
  );
}