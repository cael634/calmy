import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';

class MotivationalCard extends StatelessWidget {
  final AppState appState;
  final bool isSpanish;

  const MotivationalCard({
    super.key,
    required this.appState,
    required this.isSpanish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.green[50]!],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 32)),
          const SizedBox(height: 12),
          Text(
            isSpanish ? '¡Sigue así!' : 'Keep it up!',
            style: TextStyle(
              color: Colors.green[800],
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${appState.totalSessions} ${isSpanish ? 'sesiones completadas. Cada respiración cuenta para tu bienestar.' : 'sessions completed. Every breath counts for your wellbeing.'}',
            style: TextStyle(
              color: Colors.green[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 800.ms);
  }
}
