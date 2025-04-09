import 'dart:async';
import 'package:flutter/material.dart';

class PomodoroDialog extends StatefulWidget {
  const PomodoroDialog({super.key});

  @override
  State<PomodoroDialog> createState() => _PomodoroDialogState();
}

class _PomodoroDialogState extends State<PomodoroDialog> with SingleTickerProviderStateMixin {
  static const int workDuration = 25 * 60; // 25 минут в секундах
  static const int breakDuration = 5 * 60; // 5 минут в секундах
  
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  
  Timer? _timer;
  int _secondsRemaining = workDuration;
  bool _isBreak = false;
  bool _isRunning = false;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: workDuration),
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
    super.dispose();
  }
  
  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    
    _animationController.forward(from: 1 - (_secondsRemaining / (_isBreak ? breakDuration : workDuration)));
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          
          // Переключаемся между работой и отдыхом
          _isBreak = !_isBreak;
          _secondsRemaining = _isBreak ? breakDuration : workDuration;
          
          // Показываем уведомление
          _showNotification();
          
          // Обновляем анимацию
          _animationController.duration = Duration(seconds: _isBreak ? breakDuration : workDuration);
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
      _secondsRemaining = workDuration;
    });
    _timer?.cancel();
    _animationController.reset();
  }
  
  void _showNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBreak 
          ? 'Время отдохнуть! Сделайте перерыв на 5 минут.' 
          : 'Время работать! Сосредоточьтесь на задаче.'),
        backgroundColor: _isBreak ? Colors.green : Colors.blue,
      ),
    );
  }
  
  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isBreak ? 'Перерыв' : 'Pomodoro Таймер'),
      content: Column(
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
                      value: _isRunning ? _progressAnimation.value : 1 - (_secondsRemaining / (_isBreak ? breakDuration : workDuration)),
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
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            _isBreak 
              ? 'Время отдохнуть! Сделайте перерыв и расслабьтесь.' 
              : 'Сосредоточьтесь на задаче. Избегайте отвлечений.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
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
      ),
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
}
