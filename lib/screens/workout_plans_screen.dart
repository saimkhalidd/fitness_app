import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'workout_plan_detail_screen.dart';
import 'workout_plan_creation_screen.dart';

class WorkoutPlansScreen extends StatefulWidget {
  const WorkoutPlansScreen({super.key});

  @override
  State<WorkoutPlansScreen> createState() => _WorkoutPlansScreenState();
}

class _WorkoutPlansScreenState extends State<WorkoutPlansScreen> {
  List<Map<String, dynamic>> workoutPlans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWorkoutPlans();
  }

  Future<void> fetchWorkoutPlans() async {
    setState(() => isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("⚠️ No user signed in.");
      setState(() => isLoading = false);
      return;
    }

    try {
      print("🔍 Fetching workout plans for user: ${user.uid}");

      final snapshot =
          await FirebaseFirestore.instance
              .collection('workoutPlans')
              .where('userId', isEqualTo: user.uid)
              .get();

      print("✅ Retrieved ${snapshot.docs.length} workout plans");

      final fetchedPlans =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['docId'] = doc.id;
            return data;
          }).toList();

      setState(() {
        workoutPlans = fetchedPlans;
        isLoading = false;
      });
    } catch (e, stack) {
      print("❌ Error fetching workout plans: $e");
      print("🧱 Stack Trace:\n$stack");
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteWorkoutPlan(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('workoutPlans')
          .doc(docId)
          .delete();
      print("🗑️ Deleted plan with ID: $docId");
      await fetchWorkoutPlans();
    } catch (e) {
      print("❌ Error deleting workout plan: $e");
    }
  }

  void _navigateToCreatePlan() async {
    final newPlan = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WorkoutPlanCreationScreen()),
    );

    if (newPlan != null && newPlan is Map<String, dynamic>) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('workoutPlans').add({
        ...newPlan,
        'userId': user.uid,
      });

      fetchWorkoutPlans();
    }
  }

  void _navigateToPlanDetail(Map<String, dynamic> plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutPlanDetailScreen(workoutPlan: plan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Workout Plans',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8B0000), Color(0xFFB22222)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:
            isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                : workoutPlans.isEmpty
                ? Center(
                  child: Text(
                    'No workout plans found.\nTap "+" to create one!',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                )
                : ListView.builder(
                  padding: const EdgeInsets.only(
                    top: kToolbarHeight + 24,
                    bottom: 16,
                  ),
                  itemCount: workoutPlans.length,
                  itemBuilder: (context, index) {
                    final plan = workoutPlans[index];
                    return Card(
                      color: Colors.red.shade900.withOpacity(0.9),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(
                          plan['name'] ?? 'Unnamed Plan',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '${plan['duration'] ?? 0} minutes - ${plan['equipment']?.join(', ') ?? 'No equipment'}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white70,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder:
                                      (ctx) => AlertDialog(
                                        title: const Text('Delete Plan'),
                                        content: const Text(
                                          'Are you sure you want to delete this plan?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.of(
                                                  ctx,
                                                ).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () =>
                                                    Navigator.of(ctx).pop(true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                );
                                if (confirm == true && plan['docId'] != null) {
                                  deleteWorkoutPlan(plan['docId']);
                                }
                              },
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ],
                        ),
                        onTap: () => _navigateToPlanDetail(plan),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red.shade700,
        onPressed: _navigateToCreatePlan,
        child: const Icon(Icons.add),
      ),
    );
  }
}
