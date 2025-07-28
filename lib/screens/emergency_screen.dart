import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/language_provider.dart';
import '../widgets/gradient_background.dart';
import 'package:calmy/providers/app_state.dart' ;
import '../models/app_screen.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  bool _isBreathing = false;
  int _breathCount = 0;
  String _currentPhase = 'ready';
  int _phaseTimer = 0;
  int _exerciseCount = 0;
  bool _showFiveSenses = false;

  // Lista de colores progresivos de rojo fuerte a azul
  final List<List<Color>> _backgroundColors = [
    [const Color(0xFFDC143C), const Color(0xFFB22222), const Color(0xFF8B0000)], // Rojo fuerte inicial
    [const Color(0xFFFF6347), const Color(0xFFFF4500), const Color(0xFFDC143C)], // Rojo-naranja
    [const Color(0xFFFF8C00), const Color(0xFFFF7F50), const Color(0xFFFF6347)], // Naranja
    [const Color(0xFFFFA500), const Color(0xFFFF8C00), const Color(0xFFFF7F50)], // Naranja claro
    [const Color(0xFFFFD700), const Color(0xFFFFA500), const Color(0xFFFF8C00)], // Amarillo-naranja
    [const Color(0xFF9ACD32), const Color(0xFFFFD700), const Color(0xFFFFA500)], // Verde-amarillo
    [const Color(0xFF32CD32), const Color(0xFF9ACD32), const Color(0xFFFFD700)], // Verde
    [const Color(0xFF00CED1), const Color(0xFF32CD32), const Color(0xFF9ACD32)], // Verde-azul
    [const Color(0xFF00BFFF), const Color(0xFF00CED1), const Color(0xFF32CD32)], // Azul claro
    [const Color(0xFF4169E1), const Color(0xFF00BFFF), const Color(0xFF00CED1)], // Azul
    [const Color(0xFF0000FF), const Color(0xFF4169E1), const Color(0xFF00BFFF)], // Azul fuerte
    [const Color(0xFF000080), const Color(0xFF0000FF), const Color(0xFF4169E1)], // Azul marino
  ];

  final List<Map<String, dynamic>> _fiveSensesExercises = [
    {
      'sense': 'sight',
      'iconES': '👀',
      'iconEN': '👀',
      'titleES': 'Vista',
      'titleEN': 'Sight',
      'instructionES': 'Nombra 5 cosas que puedes ver a tu alrededor',
      'instructionEN': 'Name 5 things you can see around you',
      'examplesES': ['Una pared', 'Tus manos', 'La luz', 'Un objeto cercano', 'Las sombras'],
      'examplesEN': ['A wall', 'Your hands', 'The light', 'A nearby object', 'The shadows'],
    },
    {
      'sense': 'touch',
      'iconES': '✋',
      'iconEN': '✋',
      'titleES': 'Tacto',
      'titleEN': 'Touch',
      'instructionES': 'Identifica 4 cosas que puedes tocar',
      'instructionEN': 'Identify 4 things you can touch',
      'examplesES': ['La textura de tu ropa', 'La superficie donde estás', 'Tus manos', 'El aire en tu piel'],
      'examplesEN': ['The texture of your clothes', 'The surface you\'re on', 'Your hands', 'The air on your skin'],
    },
    {
      'sense': 'hearing',
      'iconES': '👂',
      'iconEN': '👂',
      'titleES': 'Oído',
      'titleEN': 'Hearing',
      'instructionES': 'Escucha 3 sonidos diferentes',
      'instructionEN': 'Listen for 3 different sounds',
      'examplesES': ['Tu respiración', 'Sonidos del ambiente', 'Tu corazón latiendo'],
      'examplesEN': ['Your breathing', 'Environmental sounds', 'Your heart beating'],
    },
    {
      'sense': 'smell',
      'iconES': '👃',
      'iconEN': '👃',
      'titleES': 'Olfato',
      'titleEN': 'Smell',
      'instructionES': 'Nota 2 olores que puedes percibir',
      'instructionEN': 'Notice 2 smells you can perceive',
      'examplesES': ['El aire que respiras', 'Algún aroma sutil del ambiente'],
      'examplesEN': ['The air you breathe', 'Some subtle scent in the environment'],
    },
    {
      'sense': 'taste',
      'iconES': '👅',
      'iconEN': '👅',
      'titleES': 'Gusto',
      'titleEN': 'Taste',
      'instructionES': 'Identifica 1 sabor en tu boca',
      'instructionEN': 'Identify 1 taste in your mouth',
      'examplesES': ['El sabor actual en tu boca'],
      'examplesEN': ['The current taste in your mouth'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      duration: const Duration(seconds: 8), // 4 seconds in, 4 seconds out
      vsync: this,
    );
    
    _breathingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.4,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  void _startEmergencyBreathing() {
    setState(() {
      _isBreathing = true;
      _breathCount = 0;
      _exerciseCount = 0; // Reset para empezar con rojo fuerte
      _showFiveSenses = false;
    });
    _runBreathingCycle();
  }

  void _runBreathingCycle() async {
    if (!_isBreathing) return;
    
    // Inhalar
    setState(() {
      _currentPhase = 'inhale';
      _phaseTimer = 4;
    });
    
    _breathingController.forward();
    
    for (int i = 4; i > 0; i--) {
      if (!_isBreathing) break;
      setState(() {
        _phaseTimer = i;
      });
      await Future.delayed(const Duration(seconds: 1));
    }
    
    // Exhalar
    setState(() {
      _currentPhase = 'exhale';
      _phaseTimer = 4;
    });
    
    _breathingController.reverse();
    
    for (int i = 4; i > 0; i--) {
      if (!_isBreathing) break;
      setState(() {
        _phaseTimer = i;
      });
      await Future.delayed(const Duration(seconds: 1));
    }
    
    // Completar respiración - cambiar color
    _breathCount++;
    setState(() {
      _exerciseCount = (_exerciseCount + 1).clamp(0, _backgroundColors.length - 1);
    });
    
    if (_isBreathing) {
      _runBreathingCycle();
    }
  }

  void _startFiveSenses() {
    setState(() {
      _showFiveSenses = true;
      _isBreathing = false;
    });
    _breathingController.stop();
    _breathingController.reset();
  }

  String _getPhaseText(bool isSpanish) {
    switch (_currentPhase) {
      case 'inhale':
        return isSpanish ? 'Inhala profundamente' : 'Breathe in deeply';
      case 'exhale':
        return isSpanish ? 'Exhala lentamente' : 'Breathe out slowly';
      default:
        return '';
    }
  }

  void _stopBreathing() {
    setState(() {
      _isBreathing = false;
      _showFiveSenses = false;
    });
    _breathingController.stop();
    _breathingController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isSpanish = languageProvider.isSpanish;

    // Obtener colores actuales basados en el número de respiraciones
    final currentColors = _exerciseCount < _backgroundColors.length 
        ? _backgroundColors[_exerciseCount]
        : _backgroundColors.last;

    if (_showFiveSenses) {
      return _buildFiveSensesScreen(isSpanish);
    }

    return Scaffold(
      body: GradientBackground(
        colors: currentColors,
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
                        isSpanish ? 'Modo Emergencia' : 'Emergency Mode',
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

              // Emergency message
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 48,
                    ).animate(onPlay: (controller) => controller.repeat())
                        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 1000.ms),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      isSpanish ? 'Estás a salvo' : 'You are safe',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      isSpanish 
                          ? 'Respira conmigo. Todo va a estar bien.'
                          : 'Breathe with me. Everything will be okay.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().slideY(begin: -0.3, delay: 200.ms),

              // Progress indicator
              if (_isBreathing)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${isSpanish ? 'Respiraciones completadas' : 'Breaths completed'}: $_breathCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isSpanish 
                            ? 'El color se vuelve más frío con cada respiración'
                            : 'The color gets cooler with each breath',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              // Breathing circle
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _breathingAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _isBreathing ? _breathingAnimation.value : 1.0,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.9),
                                    currentColors[0].withOpacity(0.4),
                                    currentColors[0].withOpacity(0.1),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: currentColors[0].withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      '💗',
                                      style: TextStyle(fontSize: 60),
                                    ),
                                    if (_isBreathing) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        '$_phaseTimer',
                                        style: TextStyle(
                                          color: currentColors[0],
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
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
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isSpanish 
                                  ? (_currentPhase == 'inhale' ? 'El círculo se infla, respira hacia adentro' : 'El círculo se desinfla, suelta el aire')
                                  : (_currentPhase == 'inhale' ? 'Circle inflates, breathe in' : 'Circle deflates, breathe out'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ).animate().fadeIn()
                      else
                        Text(
                          isSpanish 
                              ? 'Elige una técnica de emergencia'
                              : 'Choose an emergency technique',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ),

              // Control buttons
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    if (!_isBreathing) ...[
                      // Breathing button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _startEmergencyBreathing,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.healing, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                isSpanish ? 'Respiración de emergencia' : 'Emergency breathing',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().scale(delay: 500.ms),
                      
                      const SizedBox(height: 16),
                      
                      // Five senses button
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _startFiveSenses,
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
                              const Icon(Icons.visibility, size: 28),
                              const SizedBox(width: 12),
                              Text(
                                isSpanish ? 'Técnica de los 5 sentidos' : '5 Senses technique',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().scale(delay: 600.ms),
                    ] else
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: _stopBreathing,
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
                    
                    const SizedBox(height: 16),
                    
                    // Emergency contacts
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            isSpanish ? 'Si necesitas ayuda inmediata:' : 'If you need immediate help:',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildEmergencyButton(
                                icon: Icons.phone,
                                label: isSpanish ? 'Línea de Crisis' : 'Crisis Line',
                                onTap: () => _callEmergency('crisis'),
                              ),
                              _buildEmergencyButton(
                                icon: Icons.local_hospital,
                                label: isSpanish ? 'Emergencias' : 'Emergency',
                                onTap: () => _callEmergency('911'),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildFiveSensesScreen(bool isSpanish) {
    return Scaffold(
      body: GradientBackground(
        colors: const [
          Color(0xFF4A90E2),
          Color(0xFF357ABD),
          Color(0xFF1E3A8A),
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
                      onPressed: () => setState(() => _showFiveSenses = false),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        isSpanish ? 'Técnica de los 5 Sentidos' : '5 Senses Technique',
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

              // Instructions
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('🧠', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 16),
                    Text(
                      isSpanish 
                          ? 'Conecta con el presente usando tus sentidos'
                          : 'Connect with the present using your senses',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSpanish 
                          ? 'Esta técnica te ayuda a salir de pensamientos ansiosos'
                          : 'This technique helps you get out of anxious thoughts',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Five senses exercises
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _fiveSensesExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _fiveSensesExercises[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
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
                              Text(
                                isSpanish ? exercise['iconES'] : exercise['iconEN'],
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isSpanish ? exercise['titleES'] : exercise['titleEN'],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isSpanish ? exercise['instructionES'] : exercise['instructionEN'],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isSpanish ? 'Ejemplos:' : 'Examples:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...((isSpanish ? exercise['examplesES'] : exercise['examplesEN']) as List<String>)
                              .map((example) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Text('• ', style: TextStyle(color: Colors.blue[600])),
                                        Expanded(
                                          child: Text(
                                            example,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ],
                      ),
                    ).animate(delay: (index * 100).ms).slideX(begin: 0.3).fadeIn();
                  },
                ),
              ),

              // Back button
              Padding(
                padding: const EdgeInsets.all(32),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () => setState(() => _showFiveSenses = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle, size: 28),
                        const SizedBox(width: 12),
                        Text(
                          isSpanish ? 'Completado' : 'Completed',
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
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _callEmergency(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Llamando a $type...'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
