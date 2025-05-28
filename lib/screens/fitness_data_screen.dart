import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Route createRouteToFitnessData() {
  return PageRouteBuilder(
    pageBuilder:
        (context, animation, secondaryAnimation) => const FitnessDataScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const beginOffset = Offset(1.0, 0.0); // slide from right
      const endOffset = Offset.zero;
      final tween = Tween(
        begin: beginOffset,
        end: endOffset,
      ).chain(CurveTween(curve: Curves.easeInOut));
      final fadeTween = Tween(begin: 0.0, end: 1.0);

      return SlideTransition(
        position: animation.drive(tween),
        child: FadeTransition(
          opacity: animation.drive(fadeTween),
          child: child,
        ),
      );
    },
  );
}

class FitnessDataScreen extends StatefulWidget {
  const FitnessDataScreen({super.key});

  @override
  State<FitnessDataScreen> createState() => _FitnessDataScreenState();
}

class _FitnessDataScreenState extends State<FitnessDataScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController otherGoalController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  String? activityLevel;
  String? selectedGoal;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Active',
    'Very Active',
  ];

  final List<String> goalOptions = [
    'Lose weight',
    'Build muscle',
    'Improve endurance',
    'Get stronger',
    'Increase flexibility',
    'Maintain health',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    if (selectedGoal != 'Other') {
      _fadeController.reverse();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    weightController.dispose();
    heightController.dispose();
    otherGoalController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> saveFitnessData() async {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final goalText =
          selectedGoal == 'Other'
              ? otherGoalController.text.trim()
              : selectedGoal ?? '';

      final data = {
        'fitnessData': {
          'weight': double.tryParse(weightController.text) ?? 0,
          'height': double.tryParse(heightController.text) ?? 0,
          'goal': goalText,
          'age': int.tryParse(ageController.text) ?? 0,
          'activityLevel': activityLevel ?? '',
        },
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(data, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitness data saved successfully!')),
        );

        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Fitness Data')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Please enter your weight'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Please enter your height'
                            : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Fitness Goal'),
                items:
                    goalOptions
                        .map(
                          (goal) =>
                              DropdownMenuItem(value: goal, child: Text(goal)),
                        )
                        .toList(),
                value: selectedGoal,
                onChanged: (value) {
                  setState(() {
                    selectedGoal = value;
                    if (value == 'Other') {
                      _fadeController.forward();
                    } else {
                      _fadeController.reverse();
                      otherGoalController.clear();
                    }
                  });
                },
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Please select your fitness goal'
                            : null,
              ),

              // AnimatedSize smoothly grows/shrinks the container for the "Other" goal input
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child:
                      (selectedGoal == 'Other')
                          ? Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: TextFormField(
                              controller: otherGoalController,
                              decoration: const InputDecoration(
                                labelText: 'Enter your fitness goal',
                              ),
                              validator: (value) {
                                if (selectedGoal == 'Other') {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your fitness goal';
                                  }
                                }
                                return null;
                              },
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age <= 0) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Activity Level'),
                items:
                    activityLevels
                        .map(
                          (level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ),
                        )
                        .toList(),
                value: activityLevel,
                onChanged: (value) {
                  setState(() {
                    activityLevel = value;
                  });
                },
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Please select your activity level'
                            : null,
              ),
              const SizedBox(height: 32),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: 1.0,
                child: ElevatedButton(
                  onPressed: saveFitnessData,
                  child: const Text('Save Data'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
