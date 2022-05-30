// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clients_online_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClientsOnlineModelAdapter extends TypeAdapter<ClientsOnlineModel> {
  @override
  final int typeId = 5;

  @override
  ClientsOnlineModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClientsOnlineModel(
      fields[0] as String,
      (fields[1] as Map?)?.cast<dynamic, dynamic>(),
      fields[2] as double?,
      fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ClientsOnlineModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.clientId)
      ..writeByte(1)
      ..write(obj.location)
      ..writeByte(2)
      ..write(obj.direction)
      ..writeByte(3)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientsOnlineModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
