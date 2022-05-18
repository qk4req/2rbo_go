// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DriverModelAdapter extends TypeAdapter<DriverModel> {
  @override
  final int typeId = 4;

  @override
  DriverModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DriverModel(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
      fields[3] as String,
      fields[4] as String,
      (fields[5] as Map).cast<dynamic, dynamic>(),
      fields[6] as String,
      fields[7] as double,
      fields[8] as int,
      fields[9] as double,
      fields[10] as String,
      fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DriverModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.lastName)
      ..writeByte(2)
      ..write(obj.firstName)
      ..writeByte(3)
      ..write(obj.middleName)
      ..writeByte(4)
      ..write(obj.phoneNumber)
      ..writeByte(5)
      ..write(obj.car)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.rating)
      ..writeByte(8)
      ..write(obj.activity)
      ..writeByte(9)
      ..write(obj.balance)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
