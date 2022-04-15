// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineAdapter extends TypeAdapter<Medicine> {
  @override
  final int typeId = 0;

  @override
  Medicine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medicine(
      brandId: fields[0] as String,
      genericId: fields[1] as String,
      companyId: fields[2] as String,
      brandName: fields[3] as String,
      form: fields[4] as String,
      strength: fields[5] as String,
      price: fields[6] as String,
      packsize: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Medicine obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.brandId)
      ..writeByte(1)
      ..write(obj.genericId)
      ..writeByte(2)
      ..write(obj.companyId)
      ..writeByte(3)
      ..write(obj.brandName)
      ..writeByte(4)
      ..write(obj.form)
      ..writeByte(5)
      ..write(obj.strength)
      ..writeByte(6)
      ..write(obj.price)
      ..writeByte(7)
      ..write(obj.packsize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
