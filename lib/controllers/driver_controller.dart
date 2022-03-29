import 'dart:async';
import 'package:hive/hive.dart';

import '/models/driver_model.dart';

class DriverController {
  Box<DriverModel> repo = Hive.box('drivers');

  bool compare(Map driver) {
    return driver['updatedAt'] == repo.get(driver['id'])?.updatedAt;
  }

  bool contains(Map driver) {
    return repo.containsKey(driver['id']);
  }

  void update(Map driver, [FutureOr<dynamic> Function()? onSaved]) {
    //if (contains(driver)) {
      DriverModel d = repo.get(driver['id'])!;

      d.car = driver['car'] ?? d.car;
      d.lastName = driver['lastName'] ?? d.lastName;
      d.firstName = driver['firstName'] ?? d.firstName;
      d.middleName = driver['middleName'] ?? d.middleName;
      d.phoneNumber = driver['phoneNumber'] ?? d.phoneNumber;
      d.location = driver['location'] ?? d.location;
      d.direction = (driver['location'] as num).toDouble();// ?? d.direction;
      d.rating = (driver['rating'] as num).toDouble();// ?? d.rating;
      d.activity = driver['activity'] ?? d.activity;
      d.status = driver['status'] ?? d.status;
      d.createdAt = driver['createdAt'] ?? d.createdAt;
      d.updatedAt = driver['updatedAt'] ?? d.updatedAt;

      repo.put(d.id, d).then((_) async {
        if (onSaved != null) {
          await onSaved();
        }
      });
    //}
  }

  void create(Map driver) {
    //if (!contains(driver)) {
      DriverModel d = DriverModel(
        driver['id'],
        driver['car'],
        driver['lastName'],
        driver['firstName'],
        driver['middleName'],
        driver['phoneNumber'],
        driver['location'],
        (driver['direction'] as num).toDouble(),
        (driver['rating'] as num).toDouble(),
        driver['activity'],
        driver['status'],
        driver['createdAt'],
        driver['updatedAt']
      );

      repo.put(d.id, d);
    //}
  }
}