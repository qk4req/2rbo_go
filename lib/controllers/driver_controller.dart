import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:turbo_go/controllers/drivers_online_controller.dart';
import 'package:turbo_go/controllers/timestamp_controller.dart';
import 'package:turbo_go/models/driver_model.dart';
import 'package:turbo_go/models/drivers_online_model.dart';
import '/bloc/turbo_go_bloc.dart';

class DriverController {
  final DriversOnlineController _driversOnline = TurboGoBloc.driversOnlineController;
  final TimestampController _timestamp = TurboGoBloc.timestampController!;
  Box<DriverModel> repo = Hive.box('drivers');

  bool compare(Map driver) {
    return driver['updatedAt'] == repo.get(driver['uuid'])?.updatedAt;
  }

  bool contains(Map driver) {
    return repo.containsKey(driver['id']);
  }

  bool containsById(int id) {
    return contains({
      'id': id
    });
  }

  DriverModel? get(Map order) {
    return repo.get(order['id']);
  }

  DriverModel? getById(int id) {
    return get({
      'id': id
    });
  }

  void create(Map driver, [FutureOr<dynamic> Function()? onSaved]) {
    DriverModel d = DriverModel(
        driver['id'],
        driver['lastName'],
        driver['firstName'],
        driver['middleName'],
        driver['phoneNumber'],
        driver['car'],
        driver['status'] ?? 'active',
        driver['rating'] != null ? (driver['rating'] as num).toDouble() : 5.0,
        driver['activity'] ?? 0,
        driver['balance'] != null ? (driver['balance'] as num).toDouble() : 0.0,
        driver['avatar'],
        driver['licenseDate'],
        driver['createdAt'] ?? _timestamp.create().toString(),
        driver['updatedAt'] ?? _timestamp.create().toString()
    );

    repo.put(d.id, d);
  }

  void update(Map driver, [FutureOr<dynamic> Function()? onSaved]) {
    if (driver.isNotEmpty) {
      DriverModel d = repo.get(driver['id'])!;

      d.id = driver['id'] ?? d.id;
      d.lastName = driver['lastName'] ?? d.lastName;
      d.firstName = driver['firstName'] ?? d.firstName;
      d.middleName = driver['middleName'] ?? d.middleName;
      d.phoneNumber = driver['phoneNumber'] ?? d.phoneNumber;
      d.car = driver['car'] ?? d.car;
      d.status = driver['status'] ?? d.status;
      d.rating = driver['rating'] != null ? (driver['rating'] as num).toDouble() : d.rating;
      d.activity = driver['activity'] ?? d.activity;
      d.balance = driver['balance'] != null ? (driver['balance'] as num).toDouble() : d.balance;
      d.avatar = driver['avatar'] ?? d.avatar;
      d.licenseDate = driver['licenseDate'] ?? d.licenseDate;
      d.createdAt = driver['createdAt'] ?? d.createdAt;
      d.updatedAt = driver['updatedAt'] ?? _timestamp.create().toString();

      repo.put(d.id, d).then((_) async {
        if (onSaved != null) {
          await onSaved();
        }
      });
    }
  }
}