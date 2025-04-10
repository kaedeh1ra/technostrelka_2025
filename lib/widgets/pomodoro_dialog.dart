import 'dart:async';
import 'package:flutter/material.dart';

import '../models/task.dart';

class PomodoroDialog extends StatefulWidget {
  const PomodoroDialog({super.key, required this.task});
  final Task task;
  @override
  State<PomodoroDialog> createState() => _PomodoroDialogState();
}

class _PomodoroDialogState extends State<PomodoroDialog>
    with SingleTickerProviderStateMixin {
  static const int defaultWorkDuration = 25 * 60; // 25 минут в секундах
  static const int defaultBreakDuration = 5 * 60; // 5 минут в секундах

  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  Timer? _timer;
  int _workDuration = defaultWorkDuration;
  int _breakDuration = defaultBreakDuration;
  int _secondsRemaining = defaultWorkDuration;
  bool _isBreak = false;
  bool _isRunning = false;
  bool _isSettingsOpen = false;

  final TextEditingController _workDurationController = TextEditingController(
    text: '25',
  );
  final TextEditingController _breakDurationController = TextEditingController(
    text: '5',
  );

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: defaultWorkDuration),
    );

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _workDurationController.dispose();
    _breakDurationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _animationController.forward(
      from:
          1 - (_secondsRemaining / (_isBreak ? _breakDuration : _workDuration)),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _isBreak = !_isBreak;
          _secondsRemaining = _isBreak ? _breakDuration : _workDuration;

          // Уведомление
          _showNotification();
          _animationController.duration = Duration(
            seconds: _isBreak ? _breakDuration : _workDuration,
          );
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
    _animationController.stop();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _isBreak = false;
      _secondsRemaining = _workDuration;
    });
    _timer?.cancel();
    _animationController.reset();
  }

  void _showNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isBreak
              ? 'Время отдохнуть! Сделайте перерыв на $_breakDuration минут.'
              : 'Время работать! Сосредоточьтесь на задаче.',
        ),
        backgroundColor: _isBreak ? Colors.green : Colors.blue,
      ),
    );
  }

  void _toggleSettings() {
    setState(() {
      _isSettingsOpen = !_isSettingsOpen;
    });
  }

  void _applySettings() {
    final workMinutes = int.tryParse(_workDurationController.text) ?? 25;
    final breakMinutes = int.tryParse(_breakDurationController.text) ?? 5;

    setState(() {
      _workDuration = workMinutes * 60;
      _breakDuration = breakMinutes * 60;
      _secondsRemaining = _isBreak ? _breakDuration : _workDuration;
      _isSettingsOpen = false;
      _animationController.duration = Duration(
        seconds: _isBreak ? _breakDuration : _workDuration,
      );
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(_isBreak ? 'Перерыв' : widget.task.title),
          IconButton(
            icon: Icon(_isSettingsOpen ? Icons.close : Icons.settings),
            onPressed: _toggleSettings,
            tooltip: _isSettingsOpen ? 'Закрыть настройки' : 'Настройки',
          ),
        ],
      ),
      content: _isSettingsOpen ? _buildSettingsContent() : _buildTimerContent(),
      actions: [
        TextButton(
          onPressed: () {
            _timer?.cancel();
            Navigator.pop(context);
          },
          child: const Text('Закрыть'),
        ),
      ],
    );
  }

  Widget _buildTimerContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return CircularProgressIndicator(
                    value:
                        _isRunning
                            ? _progressAnimation.value
                            : 1 -
                                (_secondsRemaining /
                                    (_isBreak
                                        ? _breakDuration
                                        : _workDuration)),
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isBreak ? Colors.green : Colors.red,
                    ),
                  );
                },
              ),
            ),
            Text(
              _formatTime(_secondsRemaining),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          child: Text(
            _isBreak
                ? 'Время отдохнуть! Сделайте перерыв и расслабьтесь.'
                : widget.task.description.isEmpty
                ? 'Сосредоточьтесь на задаче. Избегайте отвлечений.'
                : widget.task.description,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
              onPressed: _isRunning ? _pauseTimer : _startTimer,
              iconSize: 32,
              color: _isBreak ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetTimer,
              iconSize: 32,
              color: Colors.grey[600],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Настройки таймера',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Длительность работы
        TextField(
          controller: _workDurationController,
          decoration: const InputDecoration(
            labelText: 'Длительность работы (минуты)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),

        // Длительность перерыва
        TextField(
          controller: _breakDurationController,
          decoration: const InputDecoration(
            labelText: 'Длительность перерыва (минуты)',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),

        // Кнопка применения настроек
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _applySettings,
            child: const Text('Применить'),
          ),
        ),
      ],
    );
  }
}
