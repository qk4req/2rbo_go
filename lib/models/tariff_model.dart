import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'tariff_model.g.dart';

@HiveType(typeId: 2)
class TariffModel {
  @HiveField(0)
  int id;
  @HiveField(1)
  String? name;
  @HiveField(2)
  double? baseCost = 50.0;
  @HiveField(3)
  double? ridePerMin = 10.0;
  @HiveField(4)
  double? submissionPerMin = 10.0;
  @HiveField(5)
  double? ridePerKm = 10.0;
  @HiveField(6)
  double? submissionPerKm = 10.0;
  @HiveField(7)
  double? waitPerMin = 5.0;
  @HiveField(8)
  String? createdAt;
  @HiveField(9)
  String? updatedAt;
  @HiveField(10)
  String? mapIcon;

  TariffModel(
    this.id,
    [
      this.name,
      this.mapIcon,
      this.baseCost = 50.0,
      this.ridePerMin = 10.0,
      this.submissionPerMin = 10.0,
      this.ridePerKm = 10.0,
      this.submissionPerKm = 10.0,
      this.waitPerMin = 5.0,
      this.createdAt,
      this.updatedAt,
    ]
  );
}