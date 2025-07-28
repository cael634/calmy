import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class QuickActions extends StatelessWidget {
  final bool isSpanish;
  final VoidCallback onEmergencyPressed;
  final VoidCallback onSleepPressed;

  const QuickActions({
    super.key,
    required this.isSpanish,
    required this.onEmergencyPressed,
    required this.onSleepPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            onPressed: onEmergencyPressed,
            color: Colors.red[500]!,
            icon: Icons.warning,
            label: isSpanish ? 'Emergencia' : 'Emergency',
          ).animate().scale(delay: 100.ms),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickActionButton(
            onPressed: onSleepPressed,
            color: Colors.purple[500]!,
            icon: Icons.bedtime,
            label: isSpanish ? 'Para Dormir' : 'For Sleep',
          ).animate().scale(delay: 200.ms),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required VoidCallback onPressed,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
