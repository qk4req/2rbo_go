import 'package:hive/hive.dart';

part 'drivers_online_model.g.dart';

@HiveType(typeId: 3)
class DriversOnlineModel {
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
}