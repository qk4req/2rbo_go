// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tariff_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TariffModelAdapter extends TypeAdapter<TariffModel> {
  @override
  final int typeId = 2;

  @override
  TariffModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TariffModel(
      fields[0] as int,
      fields[1] as String?,
      fields[10] as String?,
      fields[2] as double?,
      fields[3] as double?,
      fields[5] as double?,
      fields[7] as double?,
      fields[8] as String?,
      fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TariffModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.baseCost)
      ..writeByte(3)
      ..write(obj.ridePerMin)
      ..writeByte(5)
      ..write(obj.ridePerKm)
      ..writeByte(7)
      ..write(obj.waitPerMin)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.mapIcon);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TariffModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
