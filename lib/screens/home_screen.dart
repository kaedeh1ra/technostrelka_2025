import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:technostrelka_2025/screens/day_view_screen.dart';
import 'package:technostrelka_2025/screens/tetro_screen.dart';
import 'package:technostrelka_2025/screens/week_view_screen.dart';
import 'package:technostrelka_2025/screens/month_view_screen.dart';
import 'package:technostrelka_2025/widgets/add_task_bottom_sheet.dart';
import 'package:technostrelka_2025/widgets/pomodoro_dialog.dart';

import 'package:technostrelka_2025/screens/auth/prof.dart';

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

  void _showPomodoroDialog() {
    showDialog(
      context: context,
      builder: (context) => const TetroScreen(),
    );
  }

  void _showProfilePage() {
    showDialog(
      context: context,
      builder: (context) => ProfilePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange,
                  Colors.red,
                  Colors.black,
                ],
              ),
              borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30)),
            ),
          ),
          title: const Text(
            'Tizy',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.timer,
                  color: Colors.white),
              onPressed: _showPomodoroDialog,
              tooltip: 'Pomodoro',
            ),
            IconButton(
              icon: const Icon(Icons.settings,
                  color: Colors.white),
              onPressed: _showProfilePage,
              tooltip: 'ProfilePage',
              // Open settings
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'День'),
              Tab(text: 'Неделя'),
              Tab(text: 'Месяц'),
            ],
            labelColor: Colors.white,
            unselectedLabelColor: Colors
                .white54,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [DayViewScreen(), WeekViewScreen(), MonthViewScreen()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskBottomSheet,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.purple, width: 2),
          borderRadius: BorderRadius.circular(100),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange,
                  Colors.red,
                  Colors.black,
                ],
              ),
            ),
            child: const Icon(
                Icons.add),
          ),
        ),
        tooltip: 'Добавить задачу',
      ),
    );
  }
}