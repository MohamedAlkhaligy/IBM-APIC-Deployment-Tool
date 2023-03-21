// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnvironmentAdapter extends TypeAdapter<Environment> {
  @override
  final int typeId = 0;

  @override
  Environment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Environment(
      environmentID: fields[0] as String,
      environmentName: fields[1] as String,
      clientID: fields[2] as String,
      clientSecret: fields[3] as String,
      serverURL: fields[4] as String,
      username: fields[5] as String,
      password: fields[6] as String,
      creationTime: fields[8] as DateTime,
      lastVisited: fields[9] as DateTime,
      accessToken: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Environment obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.environmentID)
      ..writeByte(1)
      ..write(obj.environmentName)
      ..writeByte(2)
      ..write(obj.clientID)
      ..writeByte(3)
      ..write(obj.clientSecret)
      ..writeByte(4)
      ..write(obj.serverURL)
      ..writeByte(5)
      ..write(obj.username)
      ..writeByte(6)
      ..write(obj.password)
      ..writeByte(7)
      ..write(obj.accessToken)
      ..writeByte(8)
      ..write(obj.creationTime)
      ..writeByte(9)
      ..write(obj.lastVisited);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
