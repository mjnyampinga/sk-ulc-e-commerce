// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppBannerAdapter extends TypeAdapter<AppBanner> {
  @override
  final int typeId = 4;

  @override
  AppBanner read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppBanner(
      id: fields[0] as String,
      imageUrl: fields[1] as String,
      title: fields[2] as String,
      subtitle: fields[3] as String,
      cta: fields[4] as String,
      supplierId: fields[5] as String,
      isActive: fields[6] as bool,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AppBanner obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imageUrl)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.subtitle)
      ..writeByte(4)
      ..write(obj.cta)
      ..writeByte(5)
      ..write(obj.supplierId)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppBannerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
