import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MainMenu extends StatelessWidget {
  final bool isSpanish;
  final VoidCallback onMoodTrackerPressed;
  final VoidCallback onPetCustomizationPressed;
  final VoidCallback onAchievementsPressed;

  const MainMenu({
    super.key,
    required this.isSpanish,
    required this.onMoodTrackerPressed,
    required this.onPetCustomizationPressed,
    required this.onAchievementsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          onPressed: onMoodTrackerPressed,
          icon: Icons.book,
          iconColor: Colors.green[500]!,
          title: isSpanish ? 'Mini Diario de Autoestima' : 'Mini Self-Esteem Diary',
          subtitle: isSpanish ? 'Reflexiona sobre tu día' : 'Reflect on your day',
        ).animate().slideX(begin: -0.3, delay: 100.ms),
        
        const SizedBox(height: 12),
        
        _buildMenuItem(
          onPressed: onPetCustomizationPressed,
          icon: Icons.palette,
          iconColor: Colors.purple[500]!,
          title: isSpanish ? 'Personalizar Mascota' : 'Customize Pet',
          subtitle: isSpanish ? 'Accesorios y colores únicos' : 'Unique accessories and colors',
        ).animate().slideX(begin: 0.3, delay: 200.ms),
        
        const SizedBox(height: 12),
        
        _buildMenuItem(
          onPressed: onAchievementsPressed,
          icon: Icons.emoji_events,
          iconColor: Colors.yellow[600]!,
          title: isSpanish ? 'Logros' : 'Achievements',
          subtitle: '2/7 ${isSpanish ? 'completados' : 'completed'}',
        ).animate().slideX(begin: -0.3, delay: 300.ms),
      ],
    );
  }

  Widget _buildMenuItem({
    required VoidCallback onPressed,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
