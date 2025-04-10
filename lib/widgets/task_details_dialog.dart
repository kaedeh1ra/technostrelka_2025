import 'package:flutter/material.dart';
import 'package:technostrelka_2025/models/task1.dart';

class TaskDetailsDialog extends StatelessWidget {
  final Task task;
  
  const TaskDetailsDialog({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(task.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: task.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Description:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            task.description.isEmpty ? 'No description provided' : task.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Size: ${_getSizeText(task.size)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
  
  String _getSizeText(TaskSize size) {
    switch (size) {
      case TaskSize.small:
        return 'Small';
      case TaskSize.medium:
        return 'Medium';
      case TaskSize.large:
        return 'Large';
      case TaskSize.extraLarge:
        return 'Extra Large';
    }
  }
}
