import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'package:calmy/providers/app_state.dart';
import '../providers/pet_provider.dart';
import '../providers/time_mode_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/time_mode_selector.dart';
import '../widgets/pet_avatar.dart';
import '../models/app_screen.dart';
import '../services/timezone_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _petController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _petController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Inicializar el modo automático después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTimeMode();
    });
  }

  Future<void> _initializeTimeMode() async {
    if (_isInitialized) return;
    
    try {
      final timeModeProvider = Provider.of<TimeModeProvider>(context, listen: false);
      
      // Si es la primera vez o el modo automático está habilitado, actualizar
      if (timeModeProvider.isAutoMode) {
        await timeModeProvider.forceAutoUpdate();
      }
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing time mode: $e');
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _petController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer4<AppState, PetProvider, TimeModeProvider, LanguageProvider>(
        builder: (context, appState, petProvider, timeModeProvider, languageProvider, child) {
          final isSpanish = languageProvider.isSpanish;
          final styles = _getThemeStyles(timeModeProvider.currentMode);

          return Container(
            decoration: BoxDecoration(gradient: styles.background),
            child: Stack(
              children: [
                // Decoraciones de fondo animadas
                _buildBackgroundDecorations(timeModeProvider.currentMode),

                // Contenido principal
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Selector de tema con información de zona horaria
                        _buildTimeModeSection(timeModeProvider, isSpanish),
                        const SizedBox(height: 24),

                        // Header con mascota
                        _buildAnimatedHeader(appState, petProvider, timeModeProvider, isSpanish, styles),
                        const SizedBox(height: 24),

                        // Stats del usuario
                        _buildUserStats(appState, isSpanish, styles),
                        const SizedBox(height: 24),

                        // Progreso diario
                        _buildProgressCard(appState, isSpanish, styles),
                        const SizedBox(height: 32),

                        // Ejercicios principales
                        _buildMainExercises(appState, isSpanish, styles),
                        const SizedBox(height: 32),

                        // Sección adicional
                        _buildAdditionalSection(appState, isSpanish, styles, timeModeProvider.currentMode),
                        const SizedBox(height: 32),

                        // Acceso rápido
                        _buildQuickAccess(appState, isSpanish, styles, timeModeProvider.currentMode),
                        const SizedBox(height: 32),

                        // Mensaje motivacional
                        _buildMotivationalMessage(appState, petProvider, isSpanish, styles),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeModeSection(TimeModeProvider timeModeProvider, bool isSpanish) {
    return Column(
      children: [
        const TimeModeSelector(),
        
        // Información adicional de tiempo si está disponible
        if (timeModeProvider.isAutoMode && timeModeProvider.lastUpdate != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white.withOpacity(0.7),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  _getLocationTimeInfo(timeModeProvider, isSpanish),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _getLocationTimeInfo(TimeModeProvider provider, bool isSpanish) {
    if (provider.userTimezone == null || provider.lastUpdate == null) {
      return isSpanish ? 'Detectando ubicación...' : 'Detecting location...';
    }

    final timezone = TimezoneService.getReadableTimezone(provider.userTimezone!);
    final time = provider.lastUpdate!;
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    
    // Mostrar solo la ciudad si es muy largo
    String displayTimezone = timezone;
    if (timezone.contains('/')) {
      displayTimezone = timezone.split('/').last;
    }
    
    return '$timeString • $displayTimezone';
  }

  Widget _buildBackgroundDecorations(TimeMode currentMode) {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Stack(
          children: _getBackgroundElements(currentMode),
        );
      },
    );
  }

  List<Widget> _getBackgroundElements(TimeMode currentMode) {
    switch (currentMode) {
      case TimeMode.morning:
        return [
          // Sol
          Positioned(
            top: 40 + math.sin(_backgroundController.value * 2 * math.pi) * 10,
            right: 40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.yellow.shade200, Colors.orange.shade300],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Center(child: Text('☀️', style: TextStyle(fontSize: 32))),
            ),
          ),
          // Nubes animadas
          ...List.generate(5, (index) => _buildCloud(index)),
          // Elementos alegres
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.3,
            right: 20,
            child: const Text('🦋', style: TextStyle(fontSize: 24)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.6,
            left: MediaQuery.of(context).size.width * 0.25,
            child: const Text('🌸', style: TextStyle(fontSize: 20)),
          ),
        ];

      case TimeMode.afternoon:
        return [
          // Sol del atardecer
          Positioned(
            top: 60 + math.sin(_backgroundController.value * 2 * math.pi) * 5,
            right: 60,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.yellow.shade300, Colors.orange.shade400],
                ),
              ),
              child: const Center(child: Text('🌅', style: TextStyle(fontSize: 24))),
            ),
          ),
          // Elementos del atardecer
          ...List.generate(3, (index) => _buildSunsetCloud(index)),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5,
            left: 32,
            child: const Text('🌺', style: TextStyle(fontSize: 20)),
          ),
        ];

      default: // night
        return [
          // Luna
          Positioned(
            top: 48 + math.sin(_backgroundController.value * 2 * math.pi) * 8,
            right: 48,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.yellow.shade200,
                boxShadow: [
                  BoxShadow(
                    color: Colors.yellow.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(child: Text('🌙', style: TextStyle(fontSize: 32))),
            ),
          ),
          // Estrellas animadas
          ...List.generate(10, (index) => _buildStar(index)),
        ];
    }
  }

  Widget _buildCloud(int index) {
    final positions = [
      {'top': 80.0, 'left': 40.0},
      {'top': 128.0, 'right': 80.0},
      {'top': 160.0, 'left': 120.0},
      {'bottom': 160.0, 'right': 40.0},
      {'bottom': 240.0, 'left': 80.0},
    ];

    final pos = positions[index % positions.length];
    final offset = math.sin(_backgroundController.value * 2 * math.pi + index) * 20;

    return Positioned(
      top: pos['top'] != null ? pos['top']! + offset : null,
      bottom: pos['bottom'] != null ? pos['bottom']! + offset : null,
      left: pos['left'] != null ? pos['left']! + offset : null,
      right: pos['right'] != null ? pos['right']! + offset : null,
      child: Opacity(
        opacity: 0.6,
        child: Text('☁️', style: TextStyle(fontSize: 32 + index * 4)),
      ),
    );
  }

  Widget _buildSunsetCloud(int index) {
    final offset = math.sin(_backgroundController.value * 2 * math.pi + index) * 15;
    final positions = [
      {'top': 96.0, 'left': 48.0},
      {'top': 144.0, 'right': 96.0},
      {'bottom': 192.0, 'left': 64.0},
    ];

    final pos = positions[index % positions.length];

    return Positioned(
      top: pos['top'] != null ? pos['top']! + offset : null,
      bottom: pos['bottom'] != null ? pos['bottom']! + offset : null,
      left: pos['left'] != null ? pos['left']! + offset : null,
      right: pos['right'] != null ? pos['right']! + offset : null,
      child: const Opacity(
        opacity: 0.6,
        child: Text('☁️', style: TextStyle(fontSize: 28)),
      ),
    );
  }

  Widget _buildStar(int index) {
    final positions = [
      {'top': 80.0, 'left': 64.0},
      {'top': 128.0, 'right': 128.0},
      {'top': 192.0, 'left': 96.0},
      {'top': 256.0, 'right': 80.0},
      {'bottom': 192.0, 'left': 48.0},
      {'bottom': 256.0, 'right': 64.0},
      {'bottom': 128.0, 'left': 128.0},
      {'top': 320.0, 'left': 32.0},
      {'top': 400.0, 'right': 32.0},
      {'bottom': 320.0, 'left': 160.0},
    ];

    final pos = positions[index % positions.length];
    final twinkle = math.sin(_backgroundController.value * 4 * math.pi + index * 0.5);

    return Positioned(
      top: pos['top'],
      bottom: pos['bottom'],
      left: pos['left'],
      right: pos['right'],
      child: Opacity(
        opacity: 0.4 + (twinkle * 0.4),
        child: Text(
          index % 2 == 0 ? '⭐' : '✨',
          style: TextStyle(fontSize: 16 + (index % 3) * 4),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader(AppState appState, PetProvider petProvider, TimeModeProvider timeModeProvider, bool isSpanish, ThemeStyles styles) {
    return Column(
      children: [
        // Mascota animada
        AnimatedBuilder(
          animation: _petController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_petController.value * 0.1),
              child: PetAvatar(size: 120, petProvider: petProvider, showHeart: true),
            );
          },
        ),
        const SizedBox(height: 16),

        // Saludo personalizado con información de tiempo
        Text(
          "${timeModeProvider.getGreeting(isSpanish)} 👋",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: styles.textPrimary,
            shadows: timeModeProvider.currentMode == TimeMode.night ? [
              const Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black26,
              ),
            ] : null,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          isSpanish ? '¿Qué te gustaría hacer hoy?' : 'What would you like to do today?',
          style: TextStyle(
            fontSize: 16,
            color: styles.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUserStats(AppState appState, bool isSpanish, ThemeStyles styles) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard("${appState.level}", isSpanish ? 'Nivel' : 'Level', styles),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard("${appState.streak}", isSpanish ? 'Días seguidos 🔥' : 'Days in a row 🔥', styles),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String subtitle, ThemeStyles styles) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: styles.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: styles.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: styles.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: styles.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(AppState appState, bool isSpanish, ThemeStyles styles) {
  final progress = (appState.sessionsToday / appState.dailyGoal).clamp(0.0, 1.0); // Limitar al 100%
  final isGoalComplete = appState.sessionsToday >= appState.dailyGoal;

  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: styles.cardBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: styles.border.withOpacity(0.5)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isSpanish ? 'Progreso de Hoy' : 'Today\'s Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: styles.textPrimary,
              ),
            ),
            if (isGoalComplete)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Colors.green, Colors.teal]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      isSpanish ? '¡Meta!' : 'Goal!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${isSpanish ? 'Meta' : 'Goal'}: ${appState.dailyGoal} ${isSpanish ? 'sesiones diarias' : 'daily sessions'}',
          style: TextStyle(
            fontSize: 14,
            color: styles.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isSpanish ? 'Sesiones completadas' : 'Sessions completed',
              style: TextStyle(
                fontSize: 14,
                color: styles.textSecondary,
              ),
            ),
            Text(
              "${appState.sessionsToday}/${appState.dailyGoal}",
              style: TextStyle(
                fontSize: 14,
                color: styles.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: isGoalComplete 
                    ? const LinearGradient(colors: [Colors.green, Colors.teal])
                    : styles.accent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isGoalComplete
                  ? (isSpanish ? '¡Meta completada! 🎉' : 'Goal completed! 🎉')
                  : (isSpanish ? '¡Solo falta ${appState.dailyGoal - appState.sessionsToday} sesión${appState.dailyGoal - appState.sessionsToday == 1 ? '' : 'es'} más!' : 'Just ${appState.dailyGoal - appState.sessionsToday} more session${appState.dailyGoal - appState.sessionsToday == 1 ? '' : 's'}!'),
              style: TextStyle(
                fontSize: 12,
                color: isGoalComplete ? Colors.green : styles.textMuted,
                fontWeight: isGoalComplete ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              "${(progress * 100).round()}% ${isSpanish ? 'completado' : 'completed'}",
              style: TextStyle(
                fontSize: 12,
                color: styles.textMuted,
              ),
            ),
          ],
        ),
        if (isGoalComplete) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.withOpacity(0.1), Colors.teal.withOpacity(0.1)],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.emoji_events, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isSpanish 
                        ? 'Logro desbloqueado: ¡Constancia Diaria! +25 XP'
                        : 'Achievement unlocked: Daily Consistency! +25 XP',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

  Widget _buildMainExercises(AppState appState, bool isSpanish, ThemeStyles styles) {
    return Column(
      children: [
        _buildExerciseCard(
          title: isSpanish ? '🌀 Respiración Burbuja' : '🌀 Bubble Breathing',
          subtitle: isSpanish ? 'Técnica circular relajante' : 'Relaxing circular technique',
          badge: isSpanish ? '4-7-8 respiración ✨' : '4-7-8 breathing ✨',
          badgeColor: styles.badgeBg,
          iconColor: Colors.blue,
          styles: styles,
          onTap: () => appState.navigateToScreen(AppScreen.breathingBubble),
        ),
        const SizedBox(height: 16),
        _buildExerciseCard(
          title: isSpanish ? '🔺 Respiración Triángulo' : '🔺 Triangle Breathing',
          subtitle: isSpanish ? 'Patrón triangular equilibrado' : 'Balanced triangular pattern',
          badge: isSpanish ? '4-4-4 respiración ⭐' : '4-4-4 breathing ⭐',
          badgeColor: styles.badgeBgGreen,
          iconColor: Colors.green,
          styles: styles,
          onTap: () => appState.navigateToScreen(AppScreen.breathingTriangle),
        ),
        const SizedBox(height: 16),
        _buildExerciseCard(
          title: isSpanish ? '🚨 Ejercicio de Emergencia' : '🚨 Emergency Exercise',
          subtitle: isSpanish ? 'Para crisis de ansiedad nocturna' : 'For nocturnal anxiety crises',
          badge: isSpanish ? 'Acceso rápido 🌙' : 'Quick access 🌙',
          badgeColor: styles.badgeBgRed,
          iconColor: Colors.red,
          styles: styles,
          onTap: () => appState.navigateToScreen(AppScreen.emergency),
          isEmergency: true,
        ),
      ],
    );
  }

  Widget _buildAdditionalSection(AppState appState, bool isSpanish, ThemeStyles styles, TimeMode currentMode) {
    // Determinar opacidad basada en el modo
    double gradientOpacity = currentMode == TimeMode.night ? 0.2 : 0.8;
    
    return Column(
      children: [
        _buildGradientExerciseCard(
          title: isSpanish ? '🌙 Ejercicios para Dormir' : '🌙 Sleep Exercises',
          subtitle: isSpanish ? 'Relajación nocturna profunda' : 'Deep nocturnal relaxation',
          badge: isSpanish ? '3 ejercicios 💤' : '3 exercises 💤',
          gradientColors: [
            Colors.purple.shade500.withOpacity(gradientOpacity), 
            Colors.pink.shade500.withOpacity(gradientOpacity)
          ],
          borderColor: Colors.purple.shade400.withOpacity(0.3),
          iconColor: Colors.purple.shade300,
          icon: Icons.nightlight_round,
          styles: styles,
          onTap: () => appState.navigateToScreen(AppScreen.sleepExercises),
        ),
        const SizedBox(height: 16),
        _buildGradientExerciseCard(
          title: isSpanish ? '🌱 Ejercicios de Bienestar' : '🌱 Wellness Exercises',
          subtitle: isSpanish ? 'Diario de autoestima y reflexión' : 'Self-esteem and reflection journal',
          badge: isSpanish ? 'Crecimiento personal 🌟' : 'Personal growth 🌟',
          gradientColors: [
            Colors.teal.shade500.withOpacity(gradientOpacity), 
            Colors.green.shade500.withOpacity(gradientOpacity)
          ],
          borderColor: Colors.teal.shade400.withOpacity(0.3),
          iconColor: Colors.teal.shade300,
          icon: Icons.sentiment_satisfied,
          styles: styles,
          onTap: () => appState.navigateToScreen(AppScreen.moodTracker),
        ),
      ],
    );
  }

  Widget _buildExerciseCard({
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required Color iconColor,
    required ThemeStyles styles,
    required VoidCallback onTap,
    bool isEmergency = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: styles.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEmergency ? Colors.red.shade400.withOpacity(0.3) : styles.border.withOpacity(0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: iconColor.withOpacity(0.3),
                ),
              ),
              child: Icon(
                isEmergency ? Icons.warning : _getIconForTitle(title),
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: styles.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: styles.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: styles.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientExerciseCard({
    required String title,
    required String subtitle,
    required String badge,
    required List<Color> gradientColors,
    required Color borderColor,
    required Color iconColor,
    required IconData icon,
    required ThemeStyles styles,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.3),
                shape: BoxShape.circle,
                border: Border.all(color: iconColor.withOpacity(0.3)),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: styles.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: styles.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: iconColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccess(AppState appState, bool isSpanish, ThemeStyles styles, TimeMode currentMode) {
    return Column(
      children: [
        _buildQuickAccessItem(
          icon: Icons.sentiment_satisfied,
          iconColor: Colors.green,
          title: isSpanish ? 'Mini Diario de Autoestima' : 'Mini Self-esteem Journal',
          subtitle: isSpanish ? 'Reflexiona sobre tu día' : 'Reflect on your day',
          onTap: () => appState.navigateToScreen(AppScreen.moodTracker),
          styles: styles,
        ),
        const SizedBox(height: 12),
        _buildQuickAccessItem(
          icon: Icons.emoji_events,
          iconColor: Colors.amber.shade600,
          title: isSpanish ? 'Logros' : 'Achievements',
          subtitle: "${appState.achievements.length} ${isSpanish ? 'desbloqueados' : 'unlocked'}",
          onTap: () => appState.navigateToScreen(AppScreen.achievements),
          styles: styles,
        ),
        const SizedBox(height: 12),
        _buildQuickAccessItem(
          icon: Icons.settings,
          iconColor: Colors.purple,
          title: isSpanish ? 'Personalizar Zen 🎨' : 'Customize Zen 🎨',
          subtitle: isSpanish ? 'Personaliza tu mascota' : 'Customize your pet',
          onTap: () => appState.navigateToScreen(AppScreen.petCustomization),
          styles: styles,
        ),
      ],
    );
  }

  Widget _buildQuickAccessItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeStyles styles,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: styles.cardBg,
          foregroundColor: styles.textPrimary,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: styles.border.withOpacity(0.3)),
          ),
          elevation: 2,
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: styles.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: styles.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: styles.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationalMessage(AppState appState, PetProvider petProvider, bool isSpanish, ThemeStyles styles) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: styles.accent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.yellow.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            petProvider.getPetEmoji(),
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 12),
          Text(
            "${petProvider.config.name} ${isSpanish ? 'dice' : 'says'}: \"${isSpanish ? '¡Sigues haciendo un gran trabajo!' : 'You\'re doing great work!'}\"",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black26,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isSpanish 
                ? 'Llevas ${appState.streak} días consecutivos practicando. ¡Increíble constancia! 🌟'
                : 'You\'ve been practicing for ${appState.streak} consecutive days. Amazing consistency! 🌟',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black26,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    if (title.contains("Burbuja") || title.contains("Bubble")) return Icons.bubble_chart;
    if (title.contains("Triángulo") || title.contains("Triangle")) return Icons.change_history;
    if (title.contains("Emergencia") || title.contains("Emergency")) return Icons.warning;
    if (title.contains("Dormir") || title.contains("Sleep")) return Icons.nightlight_round;
    if (title.contains("Bienestar") || title.contains("Wellness")) return Icons.sentiment_satisfied;
    return Icons.circle;
  }

  ThemeStyles _getThemeStyles(TimeMode theme) {
    switch (theme) {
      case TimeMode.morning:
        return ThemeStyles(
          background: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF87CEEB), Color(0xFF4FC3F7), Color(0xFF26C6DA)],
          ),
          textPrimary: const Color(0xFF1A365D),
          textSecondary: const Color(0xFF1A365D),
          textMuted: const Color(0xFF2D3748),
          cardBg: Colors.white.withOpacity(0.9),
          border: Colors.white.withOpacity(0.5),
          badgeBg: const Color(0xFF3182CE).withOpacity(0.8),
          badgeBgGreen: const Color(0xFF38A169).withOpacity(0.8),
          badgeBgRed: const Color(0xFFE53E3E).withOpacity(0.8),
          accent: const LinearGradient(colors: [Color(0xFFFBD38D), Color(0xFFF6AD55)]),
        );

      case TimeMode.afternoon:
        return ThemeStyles(
          background: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFB347), Color(0xFFFFCC02), Color(0xFFFF8C42), Color(0xFF8E44AD)],
          ),
          textPrimary: const Color(0xFF553C9A),
          textSecondary: const Color(0xFF553C9A),
          textMuted: const Color(0xFF6B46C1),
          cardBg: Colors.white.withOpacity(0.9),
          border: Colors.white.withOpacity(0.4),
          badgeBg: const Color(0xFF1E40AF).withOpacity(0.9),
          badgeBgGreen: const Color(0xFF166534).withOpacity(0.9),
          badgeBgRed: const Color(0xFFB91C1C).withOpacity(0.9),
          accent: const LinearGradient(colors: [Color(0xFFF97316), Color(0xFFEC4899)]),
        );

      default: // night
        return ThemeStyles(
          background: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF581C87), Color(0xFF3730A3), Color(0xFF1E3A8A)],
          ),
          textPrimary: Colors.white,
          textSecondary: Colors.white,
          textMuted: Colors.white.withOpacity(0.7),
          cardBg: Colors.white.withOpacity(0.15), // Transparencia para modo nocturno
          border: Colors.white.withOpacity(0.3),
          badgeBg: const Color(0xFF3B82F6).withOpacity(0.8),
          badgeBgGreen: const Color(0xFF10B981).withOpacity(0.8),
          badgeBgRed: const Color(0xFFEF4444).withOpacity(0.8),
          accent: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]),
        );
    }
  }
}

class ThemeStyles {
  final LinearGradient background;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color cardBg;
  final Color border;
  final Color badgeBg;
  final Color badgeBgGreen;
  final Color badgeBgRed;
  final LinearGradient accent;

  ThemeStyles({
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.cardBg,
    required this.border,
    required this.badgeBg,
    required this.badgeBgGreen,
    required this.badgeBgRed,
    required this.accent,
  });
}
