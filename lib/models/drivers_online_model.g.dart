// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drivers_online_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DriversOnlineModelAdapter extends TypeAdapter<DriversOnlineModel> {
  @override
  final int typeId = 3;

  @override
  DriversOnlineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DriversOnlineModel(
      fields[0] as int,
      (fields[1] as Map).cast<dynamic, dynamic>(),
      (fields[2] as Map?)?.cast<dynamic, dynamic>(),
      fields[3] as double?,
      fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DriversOnlineModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.driverId)
      ..writeByte(1)
      ..write(obj.driver)
      ..writeByte(2)
      ..write(obj.location)
      ..writeByte(3)
      ..write(obj.direction)
      ..writeByte(4)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriversOnlineModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
