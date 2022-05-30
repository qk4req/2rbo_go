import 'package:hive/hive.dart';

part 'clients_online_model.g.dart';

@HiveType(typeId: 5)
class ClientsOnlineModel {
  @HiveField(0)
  String clientId;
  @HiveField(1)
  Map? location;
  @HiveField(2)
  double? direction;
  @HiveField(3)
  String updatedAt;

  ClientsOnlineModel(
      this.clientId,
      this.location,
      this.direction,
      this.updatedAt
  );
}