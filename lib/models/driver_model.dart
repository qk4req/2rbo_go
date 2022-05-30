import 'package:flutter/material.dart';
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
  @HiveField(12)
  String? avatar;

  static const Color defaultCarColor = Colors.white;
  List regNumberCar = [];

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
      this.avatar,
      this.createdAt,
      this.updatedAt
  ) {
    fetchCarRegNumber();
  }

  Color determineCarColor() {
    if (car['color'] != null) {
      String color = car['color'];
      if (color.indexOf('0x') == 0) {
        return Color(int.parse(color));
      }

      if (color.contains(',')) {
        List rgbo = color.split(',');
        if (rgbo.length < 3) return defaultCarColor;
        //if (rgbo.length == 3) {
        //  rgbo.add(1.0);
        //}
        return Color.fromRGBO(int.parse(rgbo[0]), int.parse(rgbo[1]), int.parse(rgbo[2]), /*rgbo[3]*/1.0);
      }
      //if (isset string in Colors properties)
    }

    return defaultCarColor;
  }

  List fetchCarRegNumber () {
    String _regNumberCar = car['regNumber'] as String;
    regNumberCar.addAll([
      _regNumberCar.substring(0, 1),
      _regNumberCar.substring(1, 4),
      _regNumberCar.substring(4, 6),
      _regNumberCar.substring(6, _regNumberCar.length),
    ]);

    return regNumberCar;
  }
}