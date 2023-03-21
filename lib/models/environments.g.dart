// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environments.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnvironmentsAdapter extends TypeAdapter<Environments> {
  @override
  final int typeId = 1;

  @override
  Environments read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Environments(
      (fields[0] as List).cast<Environment>(),
    );
  }

  @override
  void write(BinaryWriter writer, Environments obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj._environments);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
