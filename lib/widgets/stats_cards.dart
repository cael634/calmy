import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_state.dart';

class StatsCards extends StatelessWidget {
  final AppState appState;
  final bool isSpanish;
  final Color textColor;

  const StatsCards({
    super.key,
    required this.appState,
    required this.isSpanish,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.flash_on,
            iconColor: Colors.yellow[600]!,
            title: '${isSpanish ? 'Nivel' : 'Level'} ${appState.level}',
            subtitle: '${appState.experience} ${isSpanish ? 'XP' : 'XP'}',
          ).animate().slideX(begin: -0.3, delay: 100.ms),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department,
            iconColor: Colors.orange[600]!,
            title: '${appState.streak} ${isSpanish ? 'días' : 'days'}',
            subtitle: isSpanish ? 'Racha actual' : 'Current streak',
          ).animate().slideX(begin: 0.3, delay: 200.ms),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
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
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
