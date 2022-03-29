import 'package:hive/hive.dart';

part 'driver_model.g.dart';

@HiveType(typeId: 3)
class DriverModel {
  @HiveField(0)
  int id;
  @HiveField(1)
  Map car;
  @HiveField(2)
  String lastName;
  @HiveField(3)
  String firstName;
  @HiveField(4)
  String middleName;
  @HiveField(5)
  String phoneNumber;
  @HiveField(6)
  Map location;
  @HiveField(7)
  double direction;
  @HiveField(8)
  double rating;
  @HiveField(9)
  int activity;
  @HiveField(10)
  String status;
  @HiveField(11)
  String createdAt;
  @HiveField(12)
  String updatedAt;

  DriverModel(
        this.id,
        this.car,
        this.lastName,
        this.firstName,
        this.middleName,
        this.phoneNumber,
        this.location,
        this.direction,
        this.rating,
        this.activity,
        this.status,
        this.createdAt,
        this.updatedAt
      );
}