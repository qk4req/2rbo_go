import 'package:hive/hive.dart';

import '/bloc/turbo_go_bloc.dart';
import '/controllers/driver_controller.dart';
import '/controllers/timestamp_controller.dart';
import 'driver_model.dart';

part 'drivers_online_model.g.dart';

@HiveType(typeId: 3)
class DriversOnlineModel {
  final DriverController _driver = TurboGoBloc.driverController;
  final TimestampController _timestamp = TurboGoBloc.timestampController;

  @HiveField(0)
  int driverId;
  @HiveField(1)
  Map driver;
  @HiveField(2)
  Map? location;
  @HiveField(3)
  double? direction;
  @HiveField(4)
  String updatedAt;

  DriversOnlineModel(
        this.driverId,
        this.driver,
        this.location,
        this.direction,
        this.updatedAt
      );

  bool isOnline() {
    return (
        location != null && direction != null &&
        DateTime.parse(updatedAt).isAfter(_timestamp.create().subtract(const Duration(seconds: 30)))
    );
  }

  bool checkAvailability () {
    DriverModel c = _driver.getById(driverId)!;
    return (
        (c.balance > (c.car['tariff']['baseCost'] * c.car['tariff']['commission'])) &&
        c.status == 'active'
    );
  }
}