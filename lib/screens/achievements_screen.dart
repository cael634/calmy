import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:calmy/providers/app_state.dart' ;
import 'package:calmy/providers/language_provider.dart';
import '../widgets/gradient_background.dart';
import '../models/app_screen.dart';


class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isSpanish = languageProvider.isSpanish;

    final achievements = _getAchievements(appState, isSpanish);

    return Scaffold(
      body: GradientBackground(
        colors: const [
          Color(0xFFFFD700),
          Color(0xFFFFA500),
          Color(0xFFFF8C00),
        ],
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Provider.of<AppState>(context, listen: false).navigateTo(AppScreen.home),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        isSpanish ? 'Logros' : 'Achievements',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Stats overview
              Container(
                margin: const EdgeInsets.all(16),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.emoji_events,
                      value: '${achievements.where((a) => a['unlocked']).length}',
                      label: isSpanish ? 'Desbloqueados' : 'Unlocked',
                      color: Colors.green,
                    ),
                    _buildStatItem(
                      icon: Icons.flash_on,
                      value: '${appState.level}',
                      label: isSpanish ? 'Nivel' : 'Level',
                      color: Colors.orange,
                    ),
                    _buildStatItem(
                      icon: Icons.local_fire_department,
                      value: '${appState.streak}',
                      label: isSpanish ? 'Racha' : 'Streak',
                      color: Colors.red,
                    ),
                  ],
                ),
              ).animate().slideY(begin: -0.3, delay: 200.ms),

              // Achievements list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    return _buildAchievementCard(achievement, index)
                        .animate(delay: (index * 100).ms)
                        .slideX(begin: index.isEven ? -0.3 : 0.3)
                        .fadeIn();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement, int index) {
    final isUnlocked = achievement['unlocked'] as bool;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? Colors.green : Colors.grey[300]!,
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnlocked 
                ? Colors.green.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: isUnlocked ? 15 : 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Achievement icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUnlocked 
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    achievement['emoji'],
                    style: TextStyle(
                      fontSize: 28,
                      color: isUnlocked ? null : Colors.grey,
                    ),
                  ),
                ),
                if (!isUnlocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Achievement details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.grey[800] : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: isUnlocked ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.flash_on,
                      size: 16,
                      color: isUnlocked ? Colors.orange : Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${achievement['xp']} XP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.orange : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Level requirement
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isUnlocked ? Colors.green[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Lv.${achievement['level']}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.green[700] : Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAchievements(AppState appState, bool isSpanish) {
  return [
    {
      'id': 'first_session',
      'emoji': '🌱',
      'title': isSpanish ? 'Primer Paso' : 'First Step',
      'description': isSpanish ? 'Completa tu primera sesión' : 'Complete your first session',
      'level': 1,
      'xp': 50,
      'unlocked': appState.hasAchievement('first_session') || appState.totalSessions > 0,
    },
    {
      'id': 'daily_goal_completed',
      'emoji': '🎯',
      'title': isSpanish ? 'Constancia Diaria' : 'Daily Consistency',
      'description': isSpanish ? 'Completa tu meta diaria' : 'Complete your daily goal',
      'level': 2,
      'xp': 75,
      'unlocked': appState.hasAchievement('daily_goal_completed') || appState.sessionsToday >= appState.dailyGoal,
    },
    {
      'id': 'streak_3',
      'emoji': '🔥',
      'title': isSpanish ? 'Racha de 3' : '3-Day Streak',
      'description': isSpanish ? 'Mantén una racha de 3 días' : 'Maintain a 3-day streak',
      'level': 2,
      'xp': 100,
      'unlocked': appState.hasAchievement('streak_3') || appState.streak >= 3,
    },
    // ... resto de logros existentes
    {
      'id': 'breathing_master',
      'emoji': '🧘‍♀️',
      'title': isSpanish ? 'Respirador Zen' : 'Zen Breather',
      'description': isSpanish ? 'Completa 10 ejercicios de respiración' : 'Complete 10 breathing exercises',
      'level': 3,
      'xp': 150,
      'unlocked': appState.hasAchievement('breathing_master') || 
                 (appState.getExerciseCount('bubble') + appState.getExerciseCount('triangle')) >= 10,
    },
    {
      'id': 'mood_tracker_5',
      'emoji': '📝',
      'title': isSpanish ? 'Reflexivo' : 'Reflective',
      'description': isSpanish ? 'Escribe 5 entradas en tu diario' : 'Write 5 diary entries',
      'level': 4,
      'xp': 200,
      'unlocked': appState.hasAchievement('mood_tracker_5') || appState.getExerciseCount('mood_tracker') >= 5,
    },
    {
      'id': 'level_5',
      'emoji': '⭐',
      'title': isSpanish ? 'Estrella Brillante' : 'Bright Star',
      'description': isSpanish ? 'Alcanza el nivel 5' : 'Reach level 5',
      'level': 5,
      'xp': 250,
      'unlocked': appState.hasAchievement('level_5') || appState.level >= 5,
    },
    {
      'id': 'pet_customized',
      'emoji': '🎨',
      'title': isSpanish ? 'Personalización' : 'Customizer',
      'description': isSpanish ? 'Personaliza tu mascota' : 'Customize your pet',
      'level': 6,
      'xp': 300,
      'unlocked': appState.hasAchievement('pet_customized'),
    },
    {
      'id': 'streak_7',
      'emoji': '🏆',
      'title': isSpanish ? 'Campeón Semanal' : 'Weekly Champion',
      'description': isSpanish ? 'Mantén una racha de 7 días' : 'Maintain a 7-day streak',
      'level': 7,
      'xp': 350,
      'unlocked': appState.hasAchievement('streak_7') || appState.streak >= 7,
    },
    {
      'id': 'level_8',
      'emoji': '💎',
      'title': isSpanish ? 'Diamante' : 'Diamond',
      'description': isSpanish ? 'Alcanza el nivel 8' : 'Reach level 8',
      'level': 8,
      'xp': 400,
      'unlocked': appState.hasAchievement('level_8') || appState.level >= 8,
    },
    {
      'id': 'sessions_50',
      'emoji': '🌟',
      'title': isSpanish ? 'Superestrella' : 'Superstar',
      'description': isSpanish ? 'Completa 50 sesiones' : 'Complete 50 sessions',
      'level': 9,
      'xp': 450,
      'unlocked': appState.hasAchievement('sessions_50') || appState.totalSessions >= 50,
    },
    {
      'id': 'level_10',
      'emoji': '🎯',
      'title': isSpanish ? 'Enfocado' : 'Focused',
      'description': isSpanish ? 'Alcanza el nivel 10' : 'Reach level 10',
      'level': 10,
      'xp': 500,
      'unlocked': appState.hasAchievement('level_10') || appState.level >= 10,
    },
    {
      'id': 'streak_30',
      'emoji': '🚀',
      'title': isSpanish ? 'Cohete' : 'Rocket',
      'description': isSpanish ? 'Mantén una racha de 30 días' : 'Maintain a 30-day streak',
      'level': 11,
      'xp': 550,
      'unlocked': appState.hasAchievement('streak_30') || appState.streak >= 30,
    },
    {
      'id': 'level_12',
      'emoji': '👑',
      'title': isSpanish ? 'Rey del Zen' : 'Zen Master',
      'description': isSpanish ? 'Alcanza el nivel 12' : 'Reach level 12',
      'level': 12,
      'xp': 600,
      'unlocked': appState.hasAchievement('level_12') || appState.level >= 12,
    },
  ];
}
}
