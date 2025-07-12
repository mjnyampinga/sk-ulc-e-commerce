// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      id: fields[0] as String,
      name: fields[1] as String,
      subtitle: fields[2] as String,
      imageUrls: (fields[3] as List).cast<String>(),
      price: fields[4] as double,
      description: fields[7] as String,
      originalPrice: fields[5] as double?,
      hasDiscount: fields[6] as bool,
      quantity: fields[8] as int?,
      category: fields[9] as String?,
      userId: fields[10] as String?,
      isApproved: fields[11] as bool?,
      approvedBy: fields[12] as String?,
      approvedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.subtitle)
      ..writeByte(3)
      ..write(obj.imageUrls)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.originalPrice)
      ..writeByte(6)
      ..write(obj.hasDiscount)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.quantity)
      ..writeByte(9)
      ..write(obj.category)
      ..writeByte(10)
      ..write(obj.userId)
      ..writeByte(11)
      ..write(obj.isApproved)
      ..writeByte(12)
      ..write(obj.approvedBy)
      ..writeByte(13)
      ..write(obj.approvedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
