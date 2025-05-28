import 'package:flutter/material.dart';

class WorkoutPlanCreationScreen extends StatefulWidget {
  const WorkoutPlanCreationScreen({super.key});

  @override
  _WorkoutPlanCreationScreenState createState() =>
      _WorkoutPlanCreationScreenState();
}

class _WorkoutPlanCreationScreenState extends State<WorkoutPlanCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _equipmentController = TextEditingController();

  final List<Map<String, dynamic>> _exercises = [];

  void _addExercise() {
    // Add a new empty exercise for editing
    setState(() {
      _exercises.add({'name': '', 'sets': 0, 'reps': 0});
    });
  }

  void _savePlan() {
    if (!_formKey.currentState!.validate()) return;

    final plan = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': _nameController.text.trim(),
      'duration': int.tryParse(_durationController.text) ?? 0,
      'equipment':
          _equipmentController.text.isEmpty
              ? []
              : _equipmentController.text
                  .split(',')
                  .map((e) => e.trim())
                  .toList(),
      'exercises':
          _exercises.where((ex) => ex['name'].toString().isNotEmpty).toList(),
    };

    Navigator.pop(context, plan);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workout Plan'),
        backgroundColor: Colors.red.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Plan Name'),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter a plan name'
                            : null,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final v = int.tryParse(value ?? '');
                  if (v == null || v <= 0) return 'Enter a valid duration';
                  return null;
                },
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _equipmentController,
                decoration: const InputDecoration(
                  labelText: 'Equipment (comma separated)',
                ),
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              Text('Exercises', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              ..._exercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                return ExerciseInputCard(
                  exercise: exercise,
                  onChanged: (updated) {
                    setState(() {
                      _exercises[index] = updated;
                    });
                  },
                  onRemove: () {
                    setState(() {
                      _exercises.removeAt(index);
                    });
                  },
                );
              }),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add Exercise'),
                onPressed: _addExercise,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _savePlan,
                child: const Text('Save Plan', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExerciseInputCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final VoidCallback onRemove;

  const ExerciseInputCard({
    super.key,
    required this.exercise,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nameController = TextEditingController(text: exercise['name']);
    final setsController = TextEditingController(
      text: exercise['sets']?.toString() ?? '0',
    );
    final repsController = TextEditingController(
      text: exercise['reps']?.toString() ?? '0',
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
              onChanged: (val) {
                onChanged({...exercise, 'name': val});
              },
              style: theme.textTheme.bodyLarge,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: setsController,
                    decoration: const InputDecoration(labelText: 'Sets'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      onChanged({...exercise, 'sets': int.tryParse(val) ?? 0});
                    },
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: repsController,
                    decoration: const InputDecoration(labelText: 'Reps'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      onChanged({...exercise, 'reps': int.tryParse(val) ?? 0});
                    },
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
