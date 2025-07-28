import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BreathingExercisesCard extends StatelessWidget {
  final bool isSpanish;
  final VoidCallback onBubblePressed;
  final VoidCallback onTrianglePressed;

  const BreathingExercisesCard({
    super.key,
    required this.isSpanish,
    required this.onBubblePressed,
    required this.onTrianglePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.red[500], size: 24),
              const SizedBox(width: 8),
              Text(
                isSpanish ? 'Ejercicios de Respiración' : 'Breathing Exercises',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isSpanish ? 'Técnicas guiadas con tu mascota' : 'Guided techniques with your pet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          
          // Bubble breathing button
          _buildExerciseButton(
            onPressed: onBubblePressed,
            gradient: const LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
            ),
            icon: '🫧',
            title: isSpanish ? 'Respiración Burbuja' : 'Bubble Breathing',
            subtitle: '4-7-8 • ${isSpanish ? 'Relajación profunda' : 'Deep relaxation'}',
          ).animate().slideX(begin: -0.3, delay: 100.ms),
          
          const SizedBox(height: 12),
          
          // Triangle breathing button
          _buildExerciseButton(
            onPressed: onTrianglePressed,
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
            ),
            icon: '🔺',
            title: isSpanish ? 'Respiración Triángulo' : 'Triangle Breathing',
            subtitle: '4-4-4 • ${isSpanish ? 'Equilibrio mental' : 'Mental balance'}',
            isOutlined: true,
          ).animate().slideX(begin: 0.3, delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildExerciseButton({
    required VoidCallback onPressed,
    required Gradient gradient,
    required String icon,
    required String title,
    required String subtitle,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : null,
          foregroundColor: isOutlined ? Colors.grey[800] : Colors.white,
          elevation: isOutlined ? 0 : 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOutlined ? BorderSide(color: Colors.grey[300]!) : BorderSide.none,
          ),
        ),
        child: Container(
          decoration: isOutlined ? null : BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isOutlined ? Colors.green[100] : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isOutlined ? Colors.grey[800] : Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isOutlined ? Colors.grey[600] : Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
