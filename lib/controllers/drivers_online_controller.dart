import 'dart:async';
import 'package:hive/hive.dart';

import '/models/drivers_online_model.dart';

class DriversOnlineController {
  Box<DriversOnlineModel> repo = Hive.box('drivers_online');

  bool compare(Map driver) {
    return driver['updatedAt'] == repo.get(driver['driverId'])?.updatedAt;
  }

  bool contains(Map driver) {
    return repo.containsKey(driver['driverId']);
  }

  void update(Map driver, [bool sync = false, FutureOr<dynamic> Function()? onSaved]) {
    //if (contains(driver)) {
      DriversOnlineModel d = repo.get(driver['driverId'])!;

      d.driver = driver['driver'] ?? d.driver;
      d.location = driver['location'] ?? d.location;
      d.direction = driver['direction'] != null ? (driver['direction'] as num).toDouble() : d.direction;
      d.updatedAt = driver['updatedAt'] ?? d.updatedAt;

      repo.put(d.driverId, d).then((_) async {
        if (onSaved != null) {
          await onSaved();
        }
      });
    //}
  }

  void create(Map driver, [bool sync = false]) {
    //if (!contains(driver)) {
      DriversOnlineModel d = DriversOnlineModel(
        driver['driverId'],
        driver['driver'],
        driver['location'],
        (driver['direction'] as num).toDouble(),
        driver['updatedAt']
      );

      repo.put(d.driverId, d);
    //}
  }

  DriversOnlineModel? getById(int id) {
    return repo.get(id);
  }
}