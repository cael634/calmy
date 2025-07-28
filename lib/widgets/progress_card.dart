import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';

class ProgressCard extends StatelessWidget {
  final AppState appState;
  final bool isSpanish;

  const ProgressCard({
    super.key,
    required this.appState,
    required this.isSpanish,
  });

  @override
  Widget build(BuildContext context) {
    final progress = appState.sessionsToday / 5.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSpanish ? 'Progreso de Hoy' : 'Today\'s Progress',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${appState.sessionsToday}/5 ${isSpanish ? 'sesiones completadas' : 'sessions completed'}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
            minHeight: 8,
          ).animate().scaleX(duration: 800.ms, curve: Curves.easeOut),
          const SizedBox(height: 8),
          Text(
            isSpanish 
                ? '¡Excelente! Solo te falta 1 sesión para completar tu objetivo diario'
                : 'Excellent! You only need 1 more session to complete your daily goal',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
