import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lab_chart/features/lab/domain/entities/teacher.dart';

part 'teacher_model.g.dart';

@HiveType(typeId: 2)
class TeacherModel extends Teacher {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int colorValue;

  TeacherModel({
    required this.name,
    required Color color,
  })  : colorValue = color.value,
        super(name: name, color: color);

  factory TeacherModel.fromEntity(Teacher entity) {
    return TeacherModel(
      name: entity.name,
      color: entity.color,
    );
  }

  Teacher toEntity() {
    return Teacher(
      name: name,
      color: Color(colorValue),
    );
  }
}
