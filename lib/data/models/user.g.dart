// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 3;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      username: fields[1] as String,
      email: fields[2] as String,
      phone: fields[3] as String?,
      userType: fields[4] as String,
      createdAt: fields[5] as DateTime?,
      isOnline: fields[6] as bool,
      lastSeen: fields[7] as DateTime?,
      fcmToken: fields[8] as String?,
      dateOfBirth: fields[9] as DateTime?,
      addressLine1: fields[10] as String?,
      addressLine2: fields[11] as String?,
      city: fields[12] as String?,
      postalCode: fields[13] as String?,
      country: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.userType)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.isOnline)
      ..writeByte(7)
      ..write(obj.lastSeen)
      ..writeByte(8)
      ..write(obj.fcmToken)
      ..writeByte(9)
      ..write(obj.dateOfBirth)
      ..writeByte(10)
      ..write(obj.addressLine1)
      ..writeByte(11)
      ..write(obj.addressLine2)
      ..writeByte(12)
      ..write(obj.city)
      ..writeByte(13)
      ..write(obj.postalCode)
      ..writeByte(14)
      ..write(obj.country);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
