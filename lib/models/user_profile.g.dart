// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      name: fields[0] as String,
      monthlyIncome: fields[1] as double,
      currency: fields[2] as String,
      recurringIncomeDate: fields[3] as DateTime,
      monthlyBudget: fields[4] as double,
      savingGoal: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.monthlyIncome)
      ..writeByte(2)
      ..write(obj.currency)
      ..writeByte(3)
      ..write(obj.recurringIncomeDate)
      ..writeByte(4)
      ..write(obj.monthlyBudget)
      ..writeByte(5)
      ..write(obj.savingGoal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
