import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:calmy/providers/app_state.dart' ;
import '../providers/language_provider.dart';
import '../widgets/gradient_background.dart';
import '../models/app_screen.dart';
import '../services/audio_service.dart';
import '../widgets/sound_selector.dart';

class BreathingExerciseScreen extends StatefulWidget {
  final String exerciseType; // 'bubble' or 'triangle'

  const BreathingExerciseScreen({
    super.key,
    required this.exerciseType,
  });

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _circleController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _circleAnimation;

  bool _isBreathing = false;
  int _currentCycle = 0;
  int _totalCycles = 5;
  String _currentPhase = 'ready';
  int _phaseTimer = 0;
  String _selectedSound = AudioService.soundNone; // Por defecto sin sonido
  bool _showSoundSelector = false;

  @override
  void initState() {
    super.initState();

    _breathingController = AnimationController(
      vsync: this,
    );

    _circleController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _circleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _circleController,
      curve: Curves.easeInOut,
    ));

    _circleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _circleController.dispose();
    AudioService.stopSound(); // Detener cualquier sonido al salir
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isBreathing = true;
      _currentCycle = 1;
      _currentPhase = 'inhale';
    });

    // Iniciar sonido si está seleccionado
    if (_selectedSound != AudioService.soundNone) {
      AudioService.playSound(_selectedSound);
    }

    // Resetear la animación antes de empezar
    _breathingController.reset();
    _runBreathingCycle();
  }

  void _runBreathingCycle() async {
    if (widget.exerciseType == 'bubble') {
      // 4-7-8 breathing pattern
      await _breathingPhase('inhale', 4);
      await _breathingPhase('hold', 7);
      await _breathingPhase('exhale', 8);
    } else {
      // 4-4-4 breathing pattern
      await _breathingPhase('inhale', 4);
      await _breathingPhase('hold', 4);
      await _breathingPhase('exhale', 4);
    }

    _currentCycle++;
    if (_currentCycle <= _totalCycles && _isBreathing) {
      _runBreathingCycle();
    } else {
      _completeExercise();
    }
  }

  Future<void> _breathingPhase(String phase, int seconds) async {
    setState(() {
      _currentPhase = phase;
      _phaseTimer = seconds;
    });

    if (phase == 'inhale') {
      // Configurar duración para inhalar
      _breathingController.duration = Duration(seconds: seconds);
      _breathingController.forward();
    } else if (phase == 'exhale') {
      // Configurar duración para exhalar
      _breathingController.duration = Duration(seconds: seconds);
      _breathingController.reverse();
    }
    // En 'hold' no cambiamos la animación, se mantiene en su estado actual

    for (int i = seconds; i > 0; i--) {
      if (!_isBreathing) break;
      setState(() {
        _phaseTimer = i;
      });
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void _completeExercise() {
    setState(() {
      _isBreathing = false;
      _currentPhase = 'complete';
    });

    // Detener sonido
    AudioService.stopSound();

    // Add experience points and register the session
    final appState = Provider.of<AppState>(context, listen: false);
    appState.addExperience(50);
    appState.completeSession(widget.exerciseType); // 'bubble' or 'triangle'

    // Show completion dialog
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
            const Text('🎉', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              isSpanish ? '¡Excelente!' : 'Excellent!',
              style: const TextStyle(color: Colors.green),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isSpanish
                  ? 'Has completado tu sesión de respiración. ¡Ganaste 50 XP!'
                  : 'You completed your breathing session. You earned 50 XP!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flash_on, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    '+50 XP',
                    style: TextStyle(
                      color: Colors.green[700],
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

  void _stopBreathing() {
    setState(() {
      _isBreathing = false;
      _currentPhase = 'ready';
    });
    _breathingController.reset();

    // Detener sonido
    AudioService.stopSound();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isSpanish = languageProvider.isSpanish;

    return Scaffold(
      body: GradientBackground(
        colors: widget.exerciseType == 'bubble'
            ? const [Color(0xFF2196F3), Color(0xFF00BCD4), Color(0xFFE0F7FA)]
            : const [Color(0xFF4CAF50), Color(0xFF8BC34A), Color(0xFFE8F5E8)],
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
                        widget.exerciseType == 'bubble'
                            ? (isSpanish ? 'Respiración Burbuja' : 'Bubble Breathing')
                            : (isSpanish ? 'Respiración Triángulo' : 'Triangle Breathing'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Sound selector (mostrar solo si no está respirando)
              if (!_isBreathing && _showSoundSelector)
                Container(
                  margin: const EdgeInsets.all(16),
                  child: SoundSelector(
                    selectedSound: _selectedSound,
                    onSoundChanged: (sound) {
                      setState(() {
                        _selectedSound = sound;
                      });
                    },
                    isSpanish: isSpanish,
                  ),
                ).animate().slideY(begin: -0.3, delay: 200.ms),

              // Sound control button
              if (!_isBreathing)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showSoundSelector = !_showSoundSelector;
                          });
                        },
                        icon: Icon(
                          _showSoundSelector ? Icons.keyboard_arrow_up : Icons.volume_up,
                          size: 20,
                        ),
                        label: Text(
                          _showSoundSelector
                              ? (isSpanish ? 'Ocultar sonidos' : 'Hide sounds')
                              : AudioService.getSoundName(_selectedSound, isSpanish),
                          style: const TextStyle(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.9),
                          foregroundColor: widget.exerciseType == 'bubble'
                              ? Colors.blue[700]
                              : Colors.green[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 16),

              // Progress indicator
              if (_isBreathing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        '${isSpanish ? 'Ciclo' : 'Cycle'} $_currentCycle/$_totalCycles',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _currentCycle / _totalCycles,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 8),
                      // Indicador de sonido activo
                      if (_selectedSound != AudioService.soundNone)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AudioService.getSoundIcon(_selectedSound),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AudioService.getSoundName(_selectedSound, isSpanish),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ).animate().fadeIn(),

              // Main breathing area
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Breathing circle/shape
                      AnimatedBuilder(
                        animation: _breathingAnimation,
                        builder: (context, child) {
                          return AnimatedBuilder(
                            animation: _circleAnimation,
                            builder: (context, child) {
                              final scale = _isBreathing
                                  ? _breathingAnimation.value
                                  : _circleAnimation.value;

                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    shape: widget.exerciseType == 'bubble'
                                        ? BoxShape.circle
                                        : BoxShape.rectangle,
                                    color: Colors.white.withOpacity(0.2),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                    borderRadius: widget.exerciseType == 'triangle'
                                        ? BorderRadius.circular(20)
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.exerciseType == 'bubble' ? '🫧' : '🔺',
                                      style: const TextStyle(fontSize: 80),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Phase indicator
                      if (_isBreathing)
                        Column(
                          children: [
                            Text(
                              _getPhaseText(isSpanish),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$_phaseTimer',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ).animate().fadeIn()
                      else
                        Column(
                          children: [
                            Text(
                              isSpanish ? 'Prepárate para respirar' : 'Get ready to breathe',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.exerciseType == 'bubble'
                                  ? (isSpanish ? 'Técnica 4-7-8 para relajación profunda' : '4-7-8 technique for deep relaxation')
                                  : (isSpanish ? 'Técnica 4-4-4 para equilibrio mental' : '4-4-4 technique for mental balance'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),

              // Control buttons
              Padding(
                padding: const EdgeInsets.all(32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (_isBreathing)
                      ElevatedButton(
                        onPressed: _stopBreathing,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stop),
                            const SizedBox(width: 8),
                            Text(isSpanish ? 'Detener' : 'Stop'),
                          ],
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: _startBreathing,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: widget.exerciseType == 'bubble'
                              ? Colors.blue[700]
                              : Colors.green[700],
                          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.play_arrow, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              isSpanish ? 'Comenzar' : 'Start',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ).animate().scale(delay: 500.ms),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPhaseText(bool isSpanish) {
    switch (_currentPhase) {
      case 'inhale':
        return isSpanish ? 'Inhala - El círculo se infla' : 'Inhale - Circle inflates';
      case 'hold':
        return isSpanish ? 'Mantén - Círculo estable' : 'Hold - Circle stable';
      case 'exhale':
        return isSpanish ? 'Exhala - El círculo se desinfla' : 'Exhale - Circle deflates';
      default:
        return '';
    }
  }
}
