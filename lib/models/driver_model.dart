import 'package:hive/hive.dart';

part 'driver_model.g.dart';

@HiveType(typeId: 4)
class DriverModel {
  @HiveField(0)
  int id;
  @HiveField(1)
  String lastName;
  @HiveField(2)
  String firstName;
  @HiveField(3)
  String middleName;
  @HiveField(4)
  String phoneNumber;
  @HiveField(5)
  Map car;
  @HiveField(6)
  String status;
  @HiveField(7)
  double rating;
  @HiveField(8)
  int activity;
  @HiveField(9)
  double balance;
  @HiveField(10)
  String createdAt;
  @HiveField(11)
  String updatedAt;

  DriverModel(
      this.id,
      this.lastName,
      this.firstName,
      this.middleName,
      this.phoneNumber,
      this.car,
      this.status,
      this.rating,
      this.activity,
      this.balance,
      this.createdAt,
      this.updatedAt
  );
}