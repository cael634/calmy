import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import 'package:calmy/providers/app_state.dart' ;
import '../providers/language_provider.dart';
import '../widgets/gradient_background.dart';
import '../models/app_screen.dart';

class SleepExercisesScreen extends StatefulWidget {
  const SleepExercisesScreen({super.key});

  @override
  State<SleepExercisesScreen> createState() => _SleepExercisesScreenState();
}

class _SleepExercisesScreenState extends State<SleepExercisesScreen>
    with TickerProviderStateMixin {
  late AnimationController _starsController;
  late AnimationController _moonController;
  late AnimationController _breathingController;
  
  int _selectedExercise = 0;
  bool _isExerciseActive = false;
  int _currentStep = 0;
  String _currentPhase = '';
  int _phaseTimer = 0;

  final List<Map<String, dynamic>> _exercises = [
    {
      'id': 'progressive_relaxation',
      'titleES': 'Relajación Progresiva',
      'titleEN': 'Progressive Relaxation',
      'descriptionES': 'Relaja cada parte de tu cuerpo gradualmente',
      'descriptionEN': 'Relax each part of your body gradually',
      'duration': 10,
      'steps': [
        {'es': 'Cierra los ojos y respira profundamente', 'en': 'Close your eyes and breathe deeply'},
        {'es': 'Tensa y relaja los músculos de los pies', 'en': 'Tense and relax your feet muscles'},
        {'es': 'Sube a las pantorrillas y muslos', 'en': 'Move up to calves and thighs'},
        {'es': 'Relaja el abdomen y el pecho', 'en': 'Relax your abdomen and chest'},
        {'es': 'Tensa y suelta los brazos y manos', 'en': 'Tense and release arms and hands'},
        {'es': 'Relaja los hombros y el cuello', 'en': 'Relax shoulders and neck'},
        {'es': 'Suaviza los músculos faciales', 'en': 'Soften facial muscles'},
        {'es': 'Siente todo tu cuerpo completamente relajado', 'en': 'Feel your whole body completely relaxed'},
      ],
    },
    {
      'id': 'body_scan',
      'titleES': 'Escaneo Corporal',
      'titleEN': 'Body Scan',
      'descriptionES': 'Observa las sensaciones de tu cuerpo sin juzgar',
      'descriptionEN': 'Observe your body sensations without judgment',
      'duration': 8,
      'steps': [
        {'es': 'Acuéstate cómodamente y cierra los ojos', 'en': 'Lie down comfortably and close your eyes'},
        {'es': 'Enfócate en la sensación de tus pies', 'en': 'Focus on the sensation in your feet'},
        {'es': 'Sube lentamente por las piernas', 'en': 'Slowly move up through your legs'},
        {'es': 'Observa tu torso y abdomen', 'en': 'Observe your torso and abdomen'},
        {'es': 'Nota las sensaciones en tus brazos', 'en': 'Notice sensations in your arms'},
        {'es': 'Siente tu cuello y cabeza', 'en': 'Feel your neck and head'},
        {'es': 'Observa todo tu cuerpo como un todo', 'en': 'Observe your whole body as one'},
      ],
    },
    {
      'id': 'visualization',
      'titleES': 'Visualización Nocturna',
      'titleEN': 'Night Visualization',
      'descriptionES': 'Imagina un lugar tranquilo y relajante',
      'descriptionEN': 'Imagine a peaceful and relaxing place',
      'duration': 12,
      'steps': [
        {'es': 'Respira profundamente y cierra los ojos', 'en': 'Breathe deeply and close your eyes'},
        {'es': 'Imagina una playa tranquila bajo la luna', 'en': 'Imagine a peaceful beach under the moon'},
        {'es': 'Escucha el sonido suave de las olas', 'en': 'Listen to the gentle sound of waves'},
        {'es': 'Siente la arena tibia bajo tu cuerpo', 'en': 'Feel the warm sand beneath your body'},
        {'es': 'Observa las estrellas brillando arriba', 'en': 'Watch the stars shining above'},
        {'es': 'Respira el aire fresco del océano', 'en': 'Breathe the fresh ocean air'},
        {'es': 'Siente una profunda paz y tranquilidad', 'en': 'Feel deep peace and tranquility'},
        {'es': 'Deja que esta calma te lleve al sueño', 'en': 'Let this calm carry you to sleep'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    
    _starsController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
    
    _moonController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _starsController.dispose();
    _moonController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _isExerciseActive = true;
      _currentStep = 0;
    });
    _runExerciseStep();
  }

  void _runExerciseStep() async {
    final exercise = _exercises[_selectedExercise];
    final steps = exercise['steps'] as List<Map<String, String>>;
    
    if (_currentStep >= steps.length) {
      _completeExercise();
      return;
    }

    setState(() {
      _currentPhase = 'active';
      _phaseTimer = 60; // 60 seconds per step
    });

    // Start breathing animation
    _breathingController.repeat(reverse: true);

    for (int i = 60; i > 0; i--) {
      if (!_isExerciseActive) break;
      setState(() {
        _phaseTimer = i;
      });
      await Future.delayed(const Duration(seconds: 1));
    }

    if (_isExerciseActive) {
      setState(() {
        _currentStep++;
      });
      _runExerciseStep();
    }
  }

  void _completeExercise() {
    setState(() {
      _isExerciseActive = false;
      _currentPhase = 'complete';
    });
    
    _breathingController.stop();
    _breathingController.reset();

    final appState = Provider.of<AppState>(context, listen: false);
    appState.addExperience(100);
    appState.completeSession('sleep_exercise');

    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isSpanish = languageProvider.isSpanish;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('🌙', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              isSpanish ? '¡Dulces sueños!' : 'Sweet dreams!',
              style: const TextStyle(color: Colors.purple),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isSpanish
                  ? 'Has completado tu ejercicio de relajación. ¡Ganaste 100 XP!'
                  : 'You completed your relaxation exercise. You earned 100 XP!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    '+100 XP',
                    style: TextStyle(
                      color: Colors.purple[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AppState>(context, listen: false).navigateTo(AppScreen.home);
            },
            child: Text(isSpanish ? 'Continuar' : 'Continue'),
          ),
        ],
      ),
    );
  }

  void _stopExercise() {
    setState(() {
      _isExerciseActive = false;
      _currentPhase = '';
    });
    _breathingController.stop();
    _breathingController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isSpanish = languageProvider.isSpanish;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated night sky
            _buildNightSky(),
            
            // Main content
            SafeArea(
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
                          child: Column(
                            children: [
                              Text(
                                isSpanish ? '🌙 Ejercicios para Dormir' : '🌙 Sleep Exercises',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isSpanish ? 'Relajación profunda para un mejor descanso' : 'Deep relaxation for better rest',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  if (!_isExerciseActive) ...[
                    // Exercise selection
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Welcome message
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Column(
                                children: [
                                  const Text('✨', style: TextStyle(fontSize: 48)),
                                  const SizedBox(height: 16),
                                  Text(
                                    isSpanish ? 'Prepárate para un sueño reparador' : 'Prepare for restorative sleep',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    isSpanish 
                                        ? 'Estos ejercicios te ayudarán a relajar tu mente y cuerpo'
                                        : 'These exercises will help you relax your mind and body',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ).animate().slideY(begin: -0.3, delay: 200.ms),

                            const SizedBox(height: 32),

                            // Exercise cards
                            ...List.generate(_exercises.length, (index) {
                              final exercise = _exercises[index];
                              final isSelected = _selectedExercise == index;
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedExercise = index;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? Colors.white.withOpacity(0.2)
                                          : Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected 
                                            ? Colors.white.withOpacity(0.5)
                                            : Colors.white.withOpacity(0.2),
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  _getExerciseIcon(exercise['id']),
                                                  style: const TextStyle(fontSize: 24),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    isSpanish ? exercise['titleES'] : exercise['titleEN'],
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    isSpanish ? exercise['descriptionES'] : exercise['descriptionEN'],
                                                    style: TextStyle(
                                                      color: Colors.white.withOpacity(0.8),
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isSelected)
                                              const Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${exercise['duration']} ${isSpanish ? 'minutos' : 'minutes'}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ).animate(delay: (index * 200).ms).slideX(begin: 0.3).fadeIn();
                            }),
                          ],
                        ),
                      ),
                    ),

                    // Start button
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _startExercise,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1a1a2e),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_arrow, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                isSpanish ? 'Comenzar Ejercicio' : 'Start Exercise',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().scale(delay: 800.ms),
                  ] else ...[
                    // Active exercise view
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Progress indicator
                            Container(
                              margin: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Text(
                                    '${isSpanish ? 'Paso' : 'Step'} ${_currentStep + 1}/${_exercises[_selectedExercise]['steps'].length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: (_currentStep + 1) / _exercises[_selectedExercise]['steps'].length,
                                    backgroundColor: Colors.white.withOpacity(0.3),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ],
                              ),
                            ),

                            // Breathing circle
                            AnimatedBuilder(
                              animation: _breathingController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 + (_breathingController.value * 0.3),
                                  child: Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.3),
                                          Colors.purple.withOpacity(0.1),
                                          Colors.transparent,
                                        ],
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.5),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        '🌙',
                                        style: TextStyle(fontSize: 80),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 40),

                            // Current instruction
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 32),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    _currentStep < _exercises[_selectedExercise]['steps'].length
                                        ? (isSpanish 
                                            ? _exercises[_selectedExercise]['steps'][_currentStep]['es']
                                            : _exercises[_selectedExercise]['steps'][_currentStep]['en'])
                                        : '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '$_phaseTimer ${isSpanish ? 'segundos' : 'seconds'}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Stop button
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _stopExercise,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            side: const BorderSide(color: Colors.white, width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.stop),
                              const SizedBox(width: 8),
                              Text(
                                isSpanish ? 'Detener' : 'Stop',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNightSky() {
    return Stack(
      children: [
        // Moon
        AnimatedBuilder(
          animation: _moonController,
          builder: (context, child) {
            return Positioned(
              top: 60 + math.sin(_moonController.value * 2 * math.pi) * 10,
              right: 60,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.yellow.shade200,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🌙', style: TextStyle(fontSize: 40)),
                ),
              ),
            );
          },
        ),

        // Stars
        ...List.generate(15, (index) {
          return AnimatedBuilder(
            animation: _starsController,
            builder: (context, child) {
              final twinkle = math.sin(_starsController.value * 2 * math.pi + index * 0.5);
              return Positioned(
                top: (index * 47) % MediaQuery.of(context).size.height * 0.7,
                left: (index * 73) % MediaQuery.of(context).size.width,
                child: Opacity(
                  opacity: 0.3 + (twinkle * 0.4),
                  child: Text(
                    index % 2 == 0 ? '⭐' : '✨',
                    style: TextStyle(fontSize: 16 + (index % 3) * 4),
                  ),
                ),
              );
            },
          );
        }),

        // Clouds
        Positioned(
          top: 120,
          left: 40,
          child: Opacity(
            opacity: 0.3,
            child: Text('☁️', style: TextStyle(fontSize: 32, color: Colors.white.withOpacity(0.5))),
          ),
        ),
        Positioned(
          top: 180,
          right: 80,
          child: Opacity(
            opacity: 0.2,
            child: Text('☁️', style: TextStyle(fontSize: 28, color: Colors.white.withOpacity(0.5))),
          ),
        ),
      ],
    );
  }

  String _getExerciseIcon(String exerciseId) {
    switch (exerciseId) {
      case 'progressive_relaxation':
        return '🧘‍♀️';
      case 'body_scan':
        return '🔍';
      case 'visualization':
        return '🏖️';
      default:
        return '💤';
    }
  }
}
