import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/fitness_data_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Root());
}

class Root extends StatelessWidget {
  const Root({super.key});

  Future<bool> hasFitnessData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.exists && doc.data()?['fitnessData'] != null;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While waiting for auth stream
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final user = snapshot.data;

        // If user not signed in, show login
        if (user == null) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Fitness App',
            theme: _buildTheme(),
            home: const LoginScreen(),
            routes: _routes(),
          );
        }

        // If user signed in, check if fitness data exists
        return FutureBuilder<bool>(
          future: hasFitnessData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            final hasData = snapshot.data ?? false;

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Fitness App',
              theme: _buildTheme(),
              home: hasData ? const HomeScreen() : const FitnessDataScreen(),
              routes: _routes(),
            );
          },
        );
      },
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      primaryColor: Colors.red,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        centerTitle: true,
        titleTextStyle: GoogleFonts.anton(
          color: Colors.black,
          fontSize: 28,
          fontWeight: FontWeight.w400,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: Colors.redAccent,
      ),
    );
  }

  Map<String, WidgetBuilder> _routes() {
    return {
      '/login': (context) => const LoginScreen(),
      '/signup': (context) => const SignupScreen(),
      '/home': (context) => const HomeScreen(),
      '/fitness_data': (context) => const FitnessDataScreen(),
    };
  }
}
