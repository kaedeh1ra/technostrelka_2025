import 'package:flutter/material.dart';
import 'dart:async';
import 'package:technostrelka_2025/models/task1.dart';
import 'package:technostrelka_2025/widgets/task_piece.dart';
class TetrisBoardState extends State<TetrisBoard> {
  static const int rows = 20;
  static const int columns = 10;
  final Map<String, Map<String, int>> _taskPositions = {};
  List<List<String?>> _boardState = [];
  Timer? _fallTimer;
  String? _draggedTaskId;

  @override
  void initState() {
    super.initState();
    _initializeBoardState();
    _initializeTaskPositions();
    _startFallingTimer();
  }

  @override
  void dispose() {
    _fallTimer?.cancel();
    super.dispose();
  }

  void _startFallingTimer() {
    _fallTimer?.cancel();
    _fallTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      _makeBlocksFall();
    });
  }

  void _makeBlocksFall() {
    bool anyMoved = false;
    for (final taskId in _taskPositions.keys.toList()) {
      if (taskId == _draggedTaskId) continue;
      final taskIndex = widget.tasks.indexWhere((t) => t.id == taskId);
      if (taskIndex == -1) continue; // Skip if task not found

      final task = widget.tasks[taskIndex];
      final currentPos = _taskPositions[taskId]!;
      _removeTaskFromBoard(taskId);
      if (_isValidPosition(task, currentPos['row']! + 1, currentPos['col']!)) {
        _taskPositions[taskId] = {
          'row': currentPos['row']! + 1,
          'col': currentPos['col']!,
        };
        anyMoved = true;
      }
    }
    _updateBoardState();
    if (anyMoved) {
      setState(() {});
    }
  }

  void _initializeBoardState() {
    _boardState = List.generate(
      rows,
      (_) => List.generate(columns, (_) => null),
    );
  }

  @override
  void didUpdateWidget(TetrisBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    for (final task in widget.tasks) {
      if (!_taskPositions.containsKey(task.id)) {
        _placeNewTask(task);
      }
    }
  }

  void _initializeTaskPositions() {
    for (final task in widget.tasks) {
      _placeNewTask(task);
    }
  }

  void _placeNewTask(Task task) {
    int col = (columns ~/ 2) - (task.shape[0].length ~/ 2);
    int row = 0;
    while (!_isValidPosition(task, row, col)) {
      row++;
      if (row > rows - task.shape.length) {
        row = 0;
        break;
      }
    }

    _taskPositions[task.id] = {'row': row, 'col': col};
    _updateBoardState();
    setState(() {});
  }

  void _updateBoardState() {
    _initializeBoardState();
    for (final task in widget.tasks) {
      final position = _taskPositions[task.id];
      if (position == null) continue;

      final row = position['row']!;
      final col = position['col']!;

      for (int r = 0; r < task.shape.length; r++) {
        for (int c = 0; c < task.shape[r].length; c++) {
          if (task.shape[r][c] == 1) {
            final boardRow = row + r;
            final boardCol = col + c;

            if (boardRow >= 0 &&
                boardRow < rows &&
                boardCol >= 0 &&
                boardCol < columns) {
              _boardState[boardRow][boardCol] = task.id;
            }
          }
        }
      }
    }
  }

  void _moveTask(String taskId, int rowDelta, int colDelta) {
    if (!_taskPositions.containsKey(taskId)) return;
    final taskIndex = widget.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return; // Return if task not found

    final task = widget.tasks[taskIndex];
    final currentPos = _taskPositions[taskId]!;

    final newRow = currentPos['row']! + rowDelta;
    final newCol = currentPos['col']! + colDelta;
    _removeTaskFromBoard(taskId);

    if (_isValidPosition(task, newRow, newCol)) {
      setState(() {
        _taskPositions[taskId] = {'row': newRow, 'col': newCol};
        _updateBoardState();
      });
    } else {
      _updateBoardState();
    }
  }

  void _removeTaskFromBoard(String taskId) {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (_boardState[r][c] == taskId) {
          _boardState[r][c] = null;
        }
      }
    }
  }

  void _rotateTask(String taskId) {
    if (!_taskPositions.containsKey(taskId)) return;
    final taskIndex = widget.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return; // Return if task not found

    final task = widget.tasks[taskIndex];
    final rotatedTask = task.rotated();
    final currentPos = _taskPositions[taskId]!;
    _removeTaskFromBoard(taskId);

    if (_isValidPosition(rotatedTask, currentPos['row']!, currentPos['col']!)) {
      final newTask = Task(
        title: task.title,
        description: task.description,
        size: task.size,
        color: task.color,
        shape: rotatedTask.shape,
      );
      setState(() {
        widget.tasks[taskIndex] = newTask;
        _taskPositions[newTask.id] = currentPos;
        if (newTask.id != taskId) {
          _taskPositions.remove(taskId);
        }
        _updateBoardState();
      });
    } else {
      _updateBoardState();
    }
  }

  bool _isValidPosition(Task task, int row, int col) {
    for (int r = 0; r < task.shape.length; r++) {
      for (int c = 0; c < task.shape[r].length; c++) {
        if (task.shape[r][c] == 1) {
          final boardRow = row + r;
          final boardCol = col + c;

          if (boardRow < 0 ||
              boardRow >= rows ||
              boardCol < 0 ||
              boardCol >= columns) {
            return false;
          }

          if (_boardState[boardRow][boardCol] != null &&
              _boardState[boardRow][boardCol] != task.id) {
            return false;
          }
        }
      }
    }

    return true;
  }

  void addNewTask(Task task) {
    _placeNewTask(task);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: columns / rows,
        child: Stack(
          children: [
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
              ),
              itemCount: rows * columns,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: (MediaQuery.of(context).size.width - 32) / columns,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey.withOpacity(0.7),
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
            ...widget.tasks.map((task) {
              final position = _taskPositions[task.id];
              if (position == null) return const SizedBox.shrink();

              final cellSize =
                  (MediaQuery.of(context).size.width - 32) / columns;

              return Positioned(
                top: position['row']! * cellSize,
                left: position['col']! * cellSize,
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _draggedTaskId = task.id;
                    });
                    _fallTimer?.cancel();
                  },
                  onPanUpdate: (details) {
                    final cellSize =
                        (MediaQuery.of(context).size.width - 32) / columns;
                    final RenderBox box =
                        context.findRenderObject() as RenderBox;
                    final localPosition = box.globalToLocal(
                      details.globalPosition,
                    );
                    int newRow = (localPosition.dy / cellSize).floor();
                    int newCol = (localPosition.dx / cellSize).floor();

                    newRow = newRow - task.shape.length ~/ 2;
                    newCol = newCol - task.shape[0].length ~/ 2;

                    // Ensure we're within bounds
                    newRow = newRow.clamp(0, rows - task.shape.length);
                    newCol = newCol.clamp(0, columns - task.shape[0].length);

                    // Only update if position has changed
                    if (newRow != _taskPositions[task.id]!['row'] ||
                        newCol != _taskPositions[task.id]!['col']) {
                      // Temporarily remove the task from the board
                      _removeTaskFromBoard(task.id);

                      // Check if the new position is valid
                      if (_isValidPosition(task, newRow, newCol)) {
                        setState(() {
                          _taskPositions[task.id] = {
                            'row': newRow,
                            'col': newCol,
                          };
                          _updateBoardState();
                        });
                      } else {
                        _updateBoardState();
                      }
                    }
                  },
                  onPanEnd: (details) {
                    setState(() {
                      _draggedTaskId = null;
                    });
                    // Resume the falling timer
                    _startFallingTimer();
                  },
                  onLongPress: () {
                    _showTaskMenu(context, task);
                  },
                  child: TaskPiece(task: task),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showTaskMenu(BuildContext context, Task task) {
    // Pause the falling timer while menu is open
    _fallTimer?.cancel();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.rotate_right),
                title: const Text('Rotate Clockwise'),
                onTap: () {
                  Navigator.pop(context);
                  _rotateTask(task.id);
                  // Resume the falling timer
                  _startFallingTimer();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete Task'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteTask(task.id);
                  // Resume the falling timer
                  _startFallingTimer();
                },
              ),
            ],
          ),
        );
      },
    ).then((_) {
      // Resume the falling timer when the menu is closed
      _startFallingTimer();
    });
  }

  void _deleteTask(String taskId) {
    setState(() {
      _removeTaskFromBoard(taskId);
      _taskPositions.remove(taskId);
      widget.tasks.removeWhere((task) => task.id == taskId);
      _updateBoardState();
    });
  }
}

class TetrisBoard extends StatefulWidget {
  final List<Task> tasks;

  const TetrisBoard({Key? key, required this.tasks}) : super(key: key);

  @override
  State<TetrisBoard> createState() => TetrisBoardState();
}
