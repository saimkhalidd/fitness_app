import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import '../screens/dashboard_screen.dart'; // Contains ThemedBackground

class ProgressTrackerScreen extends StatefulWidget {
  const ProgressTrackerScreen({super.key});

  @override
  State<ProgressTrackerScreen> createState() => _ProgressTrackerScreenState();
}

class _ProgressTrackerScreenState extends State<ProgressTrackerScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  List<Map<String, dynamic>> _sessionLogs = [];

  @override
  void initState() {
    super.initState();
    _loadSessionLogs();
  }

  void _loadSessionLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('progressSessions')
            .orderBy('timestamp', descending: true)
            .get();

    setState(() {
      _sessionLogs = snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  void _startTimer() {
    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {});
      });
    }
  }

  void _pauseTimer() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _timer?.cancel();
    }
  }

  void _resetTimer() {
    _stopwatch.reset();
    _stopwatch.stop();
    _timer?.cancel();
    setState(() {});
  }

  void _endSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _stopwatch.elapsedMilliseconds == 0) return;

    final session = {
      'duration': _stopwatch.elapsed.inSeconds,
      'timestamp': Timestamp.now(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('progressSessions')
        .add(session);

    _resetTimer();
    _loadSessionLogs();
  }

  void _deleteSession(Timestamp timestamp) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final sessionsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('progressSessions');

    final snapshot =
        await sessionsRef.where('timestamp', isEqualTo: timestamp).get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    _loadSessionLogs();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemedBackground(
        child: SafeArea(
          child: Scrollbar(
            thumbVisibility: true,
            thickness: 6,
            radius: const Radius.circular(4),
            trackVisibility: false,
            interactive: true,
            scrollbarOrientation: ScrollbarOrientation.right,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Every Second Counts — Stay Consistent!',
                    style: GoogleFonts.anton(fontSize: 26, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                    ),
                    child: Text(
                      _formatDuration(_stopwatch.elapsed),
                      style: GoogleFonts.anton(fontSize: 32, color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _startTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 24,
                          ),
                        ),
                        child: const Text('Start'),
                      ),
                      ElevatedButton(
                        onPressed: _pauseTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 24,
                          ),
                        ),
                        child: const Text('Pause'),
                      ),
                      ElevatedButton(
                        onPressed: _resetTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 24,
                          ),
                        ),
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        onPressed: _endSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 24,
                          ),
                        ),
                        child: const Text('End Session'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Past Sessions',
                      style: GoogleFonts.anton(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._sessionLogs.map((session) {
                    final timestamp = session['timestamp'] as Timestamp;
                    final duration = Duration(seconds: session['duration']);
                    final date = timestamp.toDate();
                    return Card(
                      color: Colors.white.withOpacity(0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          'Duration: ${_formatDuration(duration)}',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          'Date: ${date.toLocal().toString().split(".")[0]}',
                          style: GoogleFonts.montserrat(color: Colors.white70),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteSession(timestamp),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
