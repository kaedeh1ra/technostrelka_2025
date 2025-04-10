import 'package:flutter/material.dart';
import 'package:technostrelka_2025/models/task1.dart';

class TaskPiece extends StatelessWidget {
  final Task task;

  const TaskPiece({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cellSize =
        (MediaQuery.of(context).size.width - 32) / 10; // 10 columns

    // Calculate the center position for the task name
    int centerRow = task.shape.length ~/ 2;
    int centerCol = task.shape[0].length ~/ 2;

    // Find if there's a filled cell at the center
    bool hasCenterCell =
        task.shape.length > centerRow &&
        task.shape[0].length > centerCol &&
        task.shape[centerRow][centerCol] == 1;

    // If center is not filled, find the first filled cell
    int labelRow = centerRow;
    int labelCol = centerCol;

    if (!hasCenterCell) {
      for (int r = 0; r < task.shape.length; r++) {
        bool found = false;
        for (int c = 0; c < task.shape[r].length; c++) {
          if (task.shape[r][c] == 1) {
            labelRow = r;
            labelCol = c;
            found = true;
            break;
          }
        }
        if (found) break;
      }
    }

    return Stack(
      children: [
        // Draw the shape
        Column(
          children:
              task.shape.map((row) {
                return Row(
                  children:
                      row.map((cell) {
                        return Container(
                          width: cellSize,
                          height: cellSize,
                          decoration: BoxDecoration(
                            color: cell == 1 ? task.color : Colors.transparent,
                            border:
                                cell == 1
                                    ? Border.all(
                                      color: task.color.withOpacity(0.7),
                                      width: 1,
                                    )
                                    : null,
                            borderRadius:
                                cell == 1 ? BorderRadius.circular(2) : null,
                          ),
                        );
                      }).toList(),
                );
              }).toList(),
        ),

        // Position the task name at the center or first filled cell
        Positioned(
          top: labelRow * cellSize,
          left: labelCol * cellSize,
          width: cellSize,
          height: cellSize,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  task.title,
                  style: TextStyle(
                    color: _getContrastColor(task.color),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate luminance to determine if we need white or black text
    final luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
