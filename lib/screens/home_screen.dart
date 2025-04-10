import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:technostrelka_2025/screens/day_view_screen.dart';
import 'package:technostrelka_2025/screens/tetro_screen.dart';
import 'package:technostrelka_2025/screens/week_view_screen.dart';
import 'package:technostrelka_2025/screens/month_view_screen.dart';
import 'package:technostrelka_2025/widgets/add_task_bottom_sheet.dart';
import 'package:technostrelka_2025/widgets/pomodoro_dialog.dart';

import '../models/task.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const AddTaskBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskTetris'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer),
            onPressed: () {
              // Navigator.of(context).push(
              //   MaterialPageRoute(builder: (context) => const TetroScreen()),
              // );
            },
            tooltip: 'Pomodoro',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Открыть настройки
            },
            tooltip: 'Настройки',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'День'),
            Tab(text: 'Неделя'),
            Tab(text: 'Месяц'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [DayViewScreen(), WeekViewScreen(), MonthViewScreen()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskBottomSheet,
        child: const Icon(Icons.add),
        tooltip: 'Добавить задачу',
      ),
    );
  }
}
