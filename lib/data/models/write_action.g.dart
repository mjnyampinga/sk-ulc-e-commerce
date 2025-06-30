// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'write_action.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WriteActionAdapter extends TypeAdapter<WriteAction> {
  @override
  final int typeId = 10;

  @override
  WriteAction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WriteAction(
      id: fields[0] as String,
      type: fields[1] as String,
      data: (fields[2] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, WriteAction obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WriteActionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
