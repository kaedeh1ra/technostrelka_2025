import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TaskSize { small, medium, large, extraLarge }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String category;
  final bool priority;
  final bool isCompleted;
  final DateTime createdAt;
  final TaskSize size;
  final Color? color;
  final List<List<int>>? shape;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
    required this.size,
    List<List<int>>? shape,
    Color? color,
  }) : color = color ?? _getRandomColor(),
       shape = shape ?? _getShapeForSize(size);

  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      category: data['category'] ?? 'Учёба',
      priority: data['priority'] ?? false,
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      size: TaskSize.values.firstWhere(
        (e) => e.toString() == data['size'],
        orElse: () => TaskSize.medium,
      ), // Provide a default if not found
      color: _colorFromFirestore(data['color']),
      shape: _shapeFromFirestore(data['shape']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'size': size.toString(),
      'color': _colorToFirestore(color!),
      'shape': _shapeToFirestore(shape!),
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? category,
    bool? priority,
    bool? isCompleted,
    DateTime? createdAt,
    TaskSize? size,
    Color? color,
    List<List<int>>? shape,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      size: size ?? this.size,
      color: color ?? this.color,
      shape: shape ?? this.shape,
    );
  }

  Task rotated() {
    int rows = shape!.length;
    int cols = shape![0].length;
    List<List<int>> rotatedShape = List.generate(
      cols,
      (i) => List.generate(rows, (j) => shape![rows - j - 1][i]),
    );
    return copyWith(shape: rotatedShape);
  }

  static List<List<int>> _getShapeForSize(TaskSize size) {
    switch (size) {
      case TaskSize.small:
        return [
          [1, 1],
          [1, 1],
        ];
      case TaskSize.medium:
        return [
          [1, 0],
          [1, 0],
          [1, 1],
        ];
      case TaskSize.large:
        return [
          [1, 1, 1],
          [0, 1, 0],
          [0, 1, 0],
        ];
      case TaskSize.extraLarge:
        return [
          [1, 1, 1, 1],
          [0, 0, 1, 0],
          [0, 0, 1, 0],
          [0, 0, 1, 0],
        ];
    }
  }

  static Color _getRandomColor() {
    return Color(
      (math.Random().nextDouble() * 0xFFFFFF).toInt() << 0,
    ).withOpacity(1.0);
  }

  // Helper functions for Firestore color conversion
  static Color _colorFromFirestore(dynamic data) {
    if (data is int) {
      return Color(data);
    } else if (data is String && data.startsWith('Color(')) {
      // Handle string representation from previous versions if needed
      try {
        return Color(int.parse(data.substring(6, data.length - 1)));
      } catch (e) {
        return _getRandomColor(); // Fallback to random color
      }
    }
    return _getRandomColor();
  }

  static dynamic _colorToFirestore(Color color) {
    return color.value;
  }

  // Helper functions for Firestore shape conversion
  static List<List<int>> _shapeFromFirestore(dynamic data) {
    if (data is List) {
      try {
        return List<List<int>>.from(data.map((row) => List<int>.from(row)));
      } catch (e) {
        return _getShapeForSize(TaskSize.medium); // Default shape
      }
    }
    return _getShapeForSize(TaskSize.medium);
  }

  static dynamic _shapeToFirestore(List<List<int>> shape) {
    return shape;
  }
}
