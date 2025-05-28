import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '/screens/fitness_data_screen.dart';

class ThemedBackground extends StatelessWidget {
  final Widget child;
  const ThemedBackground({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF8B0000), // Dark Red
            Color(0xFFB22222), // Firebrick Red
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<Map<String, dynamic>?> fetchFitnessData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!doc.exists) return null;

    return doc.data()?['fitnessData'] as Map<String, dynamic>?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: GoogleFonts.anton()),
        centerTitle: true,
        backgroundColor: Colors.red.shade900,
      ),
      body: ThemedBackground(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: fetchFitnessData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.red),
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return Center(
                  child: Text(
                    'No fitness data found.\nPlease add your fitness data.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                );
              }

              final data = snapshot.data!;

              Widget infoRow(String label, String value) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Text(
                        '$label:',
                        style: GoogleFonts.anton(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.red.shade200,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        value,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Your Fitness Stats',
                    style: GoogleFonts.anton(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade200,
                    ),
                  ),
                  const SizedBox(height: 24),
                  infoRow('Weight', '${data['weight']} kg'),
                  infoRow('Height', '${data['height']} cm'),
                  infoRow('Age', '${data['age']} years'),
                  infoRow('Activity Level', data['activityLevel']),
                  infoRow('Fitness Goal', data['goal']),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(createRouteToFitnessData());
        },
        icon: const Icon(Icons.edit),
        label: Text(
          'Edit Data',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.red.shade900,
      ),
    );
  }
}
