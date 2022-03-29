import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'order_model.g.dart';

@HiveType(typeId: 1)
class OrderModel {
  @HiveField(0)
  int? id;
  @HiveField(1)
  int? driverId;
  @HiveField(2)
  int? clientId;
  @HiveField(3)
  int? tariffId;
  @HiveField(4)
  String? status;
  @HiveField(5)
  int? totalTime = 0;
  @HiveField(6)
  double? totalSum = 0;
  @HiveField(7)
  int? startedAt;
  @HiveField(8)
  String? createdAt;
  @HiveField(9)
  String? updatedAt;
  @HiveField(10)
  Map? from;
  @HiveField(11)
  Map? whither;
  @HiveField(12)
  String? comment = '';

  OrderModel(
      [
        this.id,
        this.driverId,
        this.clientId,
        this.tariffId,
        this.status,
        this.totalTime=0,
        this.totalSum=0,
        this.from,
        this.whither,
        this.comment = '',
        this.startedAt,
        this.createdAt,
        this.updatedAt
      ]
  );
}