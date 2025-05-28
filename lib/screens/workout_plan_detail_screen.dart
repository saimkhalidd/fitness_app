import 'dart:async';
import 'package:flutter/material.dart';

class WorkoutPlanDetailScreen extends StatefulWidget {
  final Map<String, dynamic> workoutPlan;
  const WorkoutPlanDetailScreen({required this.workoutPlan, super.key});

  @override
  _WorkoutPlanDetailScreenState createState() =>
      _WorkoutPlanDetailScreenState();
}

class _WorkoutPlanDetailScreenState extends State<WorkoutPlanDetailScreen> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isRunning = false;

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;

    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _elapsedSeconds = 0;
      _isRunning = false;
    });
  }

  String get _formattedTime {
    final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.workoutPlan;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          plan['name'] ?? 'Workout Plan',
          style: theme.textTheme.titleLarge,
        ),
        backgroundColor: Colors.red.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duration: ${plan['duration'] ?? 'N/A'} minutes',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Equipment: ${plan['equipment']?.join(', ') ?? 'None'}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text('Exercises:', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: plan['exercises']?.length ?? 0,
                itemBuilder: (context, index) {
                  final exercise = plan['exercises'][index];
                  return ListTile(
                    title: Text(
                      exercise['name'] ?? 'Exercise',
                      style: theme.textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      '${exercise['sets']} sets x ${exercise['reps']} reps',
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Center(
              child: Text(
                _formattedTime,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isRunning ? Colors.grey : Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  onPressed: _isRunning ? null : _startTimer,
                  child: const Text('Start'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        !_isRunning ? Colors.grey : Colors.red.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  onPressed: _isRunning ? _pauseTimer : null,
                  child: const Text('Pause'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  onPressed: _resetTimer,
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
