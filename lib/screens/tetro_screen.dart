import 'package:flutter/material.dart';
import 'package:technostrelka_2025/models/task.dart';
import 'package:technostrelka_2025/widgets/tetris_board.dart';

class TetroScreen extends StatefulWidget {
  const TetroScreen({Key? key}) : super(key: key);

  @override
  State<TetroScreen> createState() => _TetroScreenState();
}

class _TetroScreenState extends State<TetroScreen> {
  final List<Task> _tasks = [];
  final GlobalKey<TetrisBoardState> _tetrisBoardKey =
      GlobalKey<TetrisBoardState>();

  void _addTask(Task task) {
    setState(() {
      _tasks.add(task);
    });

    // Notify the board about the new task
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_tetrisBoardKey.currentState != null) {
        _tetrisBoardKey.currentState!.addNewTask(task);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tetris Task Manager'), elevation: 0),
      body: Column(
        children: [
          Expanded(child: TetrisBoard(key: _tetrisBoardKey, tasks: _tasks)),
        ],
      ),
    );
  }
}
