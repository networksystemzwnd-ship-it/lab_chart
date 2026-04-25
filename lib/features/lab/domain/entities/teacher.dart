import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents a teacher in the lab scheduling domain.
///
/// This entity is intentionally lightweight and focuses on the data
/// required for allocation and display.
class Teacher extends Equatable {
  final String name;
  final Color color;

  const Teacher({required this.name, required this.color});

  @override
  List<Object> get props => [name, color.value];
}
