// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IncomeAdapter extends TypeAdapter<Income> {
  @override
  final int typeId = 2;

  @override
  Income read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Income(
      id: fields[0] as String,
      source: fields[1] as String,
      amount: fields[2] as double,
      date: fields[3] as DateTime,
      notes: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Income obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.source)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncomeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IncomeSourceAdapter extends TypeAdapter<IncomeSource> {
  @override
  final int typeId = 3;

  @override
  IncomeSource read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return IncomeSource.salary;
      case 1:
        return IncomeSource.freelance;
      case 2:
        return IncomeSource.investment;
      case 3:
        return IncomeSource.gift;
      case 4:
        return IncomeSource.other;
      default:
        return IncomeSource.salary;
    }
  }

  @override
  void write(BinaryWriter writer, IncomeSource obj) {
    switch (obj) {
      case IncomeSource.salary:
        writer.writeByte(0);
        break;
      case IncomeSource.freelance:
        writer.writeByte(1);
        break;
      case IncomeSource.investment:
        writer.writeByte(2);
        break;
      case IncomeSource.gift:
        writer.writeByte(3);
        break;
      case IncomeSource.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncomeSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
