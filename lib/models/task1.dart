import 'package:flutter/material.dart';
import 'dart:math';

enum TaskSize { small, medium, large, extraLarge }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskSize size;
  final Color color;
  final List<List<int>> shape;
  
  Task({
    required this.title,
    required this.description,
    required this.size,
    Color? color,
    List<List<int>>? shape,
    String? id,
  }) : 
    id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    color = color ?? _getRandomColor(),
    shape = shape ?? _getShapeForSize(size);
  
  static Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
    ];
    return colors[Random().nextInt(colors.length)];
  }
  
  static List<List<int>> _getShapeForSize(TaskSize size) {
    switch (size) {
      case TaskSize.small:
        // Small 2x2 square
        return [
          [1, 1],
          [1, 1]
        ];
      case TaskSize.medium:
        // Medium L shape
        return [
          [1, 0],
          [1, 0],
          [1, 1]
        ];
      case TaskSize.large:
        // Large T shape
        return [
          [1, 1, 1],
          [0, 1, 0],
          [0, 1, 0]
        ];
      case TaskSize.extraLarge:
        // Extra large shape
        return [
          [1, 1, 1, 1],
          [0, 0, 1, 0],
          [0, 0, 1, 0],
          [0, 0, 1, 0]
        ];
    }
  }
  
  Task copyWith({
    String? title,
    String? description,
    TaskSize? size,
    Color? color,
    List<List<int>>? shape,
  }) {
    return Task(
      id: this.id, // Keep the same ID
      title: title ?? this.title,
      description: description ?? this.description,
      size: size ?? this.size,
      color: color ?? this.color,
      shape: shape ?? this.shape,
    );
  }
  
  // Rotate the shape 90 degrees clockwise
  Task rotated() {
    int rows = shape.length;
    int cols = shape[0].length;
    
    List<List<int>> rotatedShape = List.generate(
      cols, 
      (i) => List.generate(rows, (j) => shape[rows - j - 1][i])
    );
    
    return Task(
      id: this.id, // Keep the same ID
      title: title,
      description: description,
      size: size,
      color: color,
      shape: rotatedShape,
    );
  }
}
