import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:turbo_go/bloc/turbo_go_bloc.dart';
import 'package:turbo_go/controllers/timestamp_controller.dart';

part 'driver_model.g.dart';

@HiveType(typeId: 4)
class DriverModel {
  final TimestampController _timestamp = TurboGoBloc.timestampController!;

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
  @HiveField(13)
  String licenseDate;

  static const Color defaultCarColor = Colors.white;
  List regNumberCar = [];
  Map experience = {};

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
      this.licenseDate,
      this.createdAt,
      this.updatedAt
  ) {
    fetchCarRegNumber();
    fetchExperience();
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

  Map fetchExperience() {
    DateTime now = _timestamp.create();
    DateTime ld = DateTime.parse(licenseDate);
    experience['years'] = (now.difference(ld).inDays / 365).round();
    List words = ['год', 'года', 'лет'];

    int n = experience['years'] % 100;
    if (n > 19) {
      n = n % 10;
    }

    switch (n) {
      case 1:
        experience['ending'] = words[0];
        break;

      case 2:
      case 3:
      case 4:
      experience['ending'] = words[1];
        break;

      default:
        experience['ending'] = words[2];
    }

    return experience;
  }
}