// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 4;

  @override
  ExpenseCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExpenseCategory.food;
      case 1:
        return ExpenseCategory.transportation;
      case 2:
        return ExpenseCategory.utilities;
      case 3:
        return ExpenseCategory.entertainment;
      case 4:
        return ExpenseCategory.shopping;
      case 5:
        return ExpenseCategory.health;
      case 6:
        return ExpenseCategory.education;
      case 7:
        return ExpenseCategory.other;
      default:
        return ExpenseCategory.food;
    }
  }

  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    switch (obj) {
      case ExpenseCategory.food:
        writer.writeByte(0);
        break;
      case ExpenseCategory.transportation:
        writer.writeByte(1);
        break;
      case ExpenseCategory.utilities:
        writer.writeByte(2);
        break;
      case ExpenseCategory.entertainment:
        writer.writeByte(3);
        break;
      case ExpenseCategory.shopping:
        writer.writeByte(4);
        break;
      case ExpenseCategory.health:
        writer.writeByte(5);
        break;
      case ExpenseCategory.education:
        writer.writeByte(6);
        break;
      case ExpenseCategory.other:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
