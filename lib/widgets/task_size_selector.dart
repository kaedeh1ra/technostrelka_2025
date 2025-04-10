import 'package:flutter/material.dart';
import 'package:technostrelka_2025/models/task1.dart';

class TaskSizeSelector extends StatelessWidget {
  final TaskSize selectedSize;
  final Function(TaskSize) onSizeChanged;

  const TaskSizeSelector({
    Key? key,
    required this.selectedSize,
    required this.onSizeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildSizeOption(context, TaskSize.small, 'Small'),
        _buildSizeOption(context, TaskSize.medium, 'Medium'),
        _buildSizeOption(context, TaskSize.large, 'Large'),
        _buildSizeOption(context, TaskSize.extraLarge, 'Extra Large'),
      ],
    );
  }

  Widget _buildSizeOption(BuildContext context, TaskSize size, String label) {
    final isSelected = selectedSize == size;

    return GestureDetector(
      onTap: () => onSizeChanged(size),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).dividerColor,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _getIconForSize(size),
              color:
                  isSelected ? Colors.white : Theme.of(context).iconTheme.color,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForSize(TaskSize size) {
    switch (size) {
      case TaskSize.small:
        return Icons.crop_square;
      case TaskSize.medium:
        return Icons.extension;
      case TaskSize.large:
        return Icons.dashboard;
      case TaskSize.extraLarge:
        return Icons.apps;
    }
  }
}
