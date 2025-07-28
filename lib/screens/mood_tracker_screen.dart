import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:calmy/providers/app_state.dart' ;
import '../providers/language_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import '../models/app_screen.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reflectionController = TextEditingController();
  final _gratitudeController = TextEditingController();
  final _goalController = TextEditingController();
  
  String _selectedMood = '';
  int _currentStep = 0;
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😢', 'label': 'Muy triste', 'labelEN': 'Very sad', 'value': 'very_sad'},
    {'emoji': '😔', 'label': 'Triste', 'labelEN': 'Sad', 'value': 'sad'},
    {'emoji': '😐', 'label': 'Neutral', 'labelEN': 'Neutral', 'value': 'neutral'},
    {'emoji': '😊', 'label': 'Feliz', 'labelEN': 'Happy', 'value': 'happy'},
    {'emoji': '😄', 'label': 'Muy feliz', 'labelEN': 'Very happy', 'value': 'very_happy'},
  ];

  @override
  void dispose() {
    _reflectionController.dispose();
    _gratitudeController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _submitEntry() async {
    if (!_formKey.currentState!.validate() || _selectedMood.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Provider.of<LanguageProvider>(context, listen: false).isSpanish
                ? 'Por favor completa todos los campos'
                : 'Please complete all fields',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Simulate saving delay
      await Future.delayed(const Duration(seconds: 2));
      
      final appState = Provider.of<AppState>(context, listen: false);
      final isSpanish = Provider.of<LanguageProvider>(context, listen: false).isSpanish;
      
      // Add experience and complete session
      appState.addExperience(75);
      appState.completeSession('mood_tracker');
      
      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  isSpanish ? '¡Reflexión guardada!' : 'Reflection saved!',
                  style: const TextStyle(color: Colors.green),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSpanish
                      ? 'Tu entrada ha sido guardada. ¡Ganaste 75 XP por reflexionar!'
                      : 'Your entry has been saved. You earned 75 XP for reflecting!',
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
                        '+75 XP',
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
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isSpanish = languageProvider.isSpanish;

    return Scaffold(
      body: GradientBackground(
        colors: const [
          Color(0xFF4facfe),
          Color(0xFF00f2fe),
          Color(0xFFa8edea),
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
                      child: Column(
                        children: [
                          Text(
                            isSpanish ? '📝 Mini Diario de Autoestima' : '📝 Mini Self-esteem Journal',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSpanish ? 'Reflexiona sobre tu día' : 'Reflect on your day',
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

              // Progress indicator
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                        decoration: BoxDecoration(
                          color: index <= _currentStep 
                              ? Colors.white 
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_currentStep == 0) _buildMoodSelection(isSpanish),
                        if (_currentStep == 1) _buildReflectionStep(isSpanish),
                        if (_currentStep == 2) _buildGratitudeStep(isSpanish),
                        if (_currentStep == 3) _buildGoalStep(isSpanish),
                      ],
                    ),
                  ),
                ),
              ),

              // Navigation buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: CustomButton(
                          text: isSpanish ? 'Anterior' : 'Previous',
                          onPressed: () {
                            setState(() {
                              _currentStep--;
                            });
                          },
                          backgroundColor: Colors.white.withOpacity(0.2),
                          textColor: Colors.white,
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: _currentStep < 3 
                            ? (isSpanish ? 'Siguiente' : 'Next')
                            : (isSpanish ? 'Guardar Reflexión' : 'Save Reflection'),
                        onPressed: _currentStep < 3 
                            ? () {
                                if (_currentStep == 0 && _selectedMood.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isSpanish ? 'Por favor selecciona tu estado de ánimo' : 'Please select your mood',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }
                                setState(() {
                                  _currentStep++;
                                });
                              }
                            : _submitEntry,
                        isLoading: _isSubmitting,
                        backgroundColor: Colors.white,
                        textColor: const Color(0xFF4facfe),
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

  Widget _buildMoodSelection(bool isSpanish) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('💭', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            isSpanish ? '¿Cómo te sientes hoy?' : 'How are you feeling today?',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4facfe),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isSpanish 
                ? 'Selecciona el emoji que mejor represente tu estado de ánimo'
                : 'Select the emoji that best represents your mood',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _moods.map((mood) {
              final isSelected = _selectedMood == mood['value'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMood = mood['value'];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF4facfe).withOpacity(0.1)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFF4facfe)
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        mood['emoji'],
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isSpanish ? mood['label'] : mood['labelEN'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? const Color(0xFF4facfe)
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: (_moods.indexOf(mood) * 100).ms).scale();
            }).toList(),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, delay: 200.ms);
  }

  Widget _buildReflectionStep(bool isSpanish) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🤔', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            isSpanish ? 'Reflexiona sobre tu día' : 'Reflect on your day',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4facfe),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isSpanish 
                ? 'Escribe sobre lo que pasó hoy y cómo te hizo sentir'
                : 'Write about what happened today and how it made you feel',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CustomInput(
            labelText: isSpanish ? 'Mi reflexión del día' : 'My daily reflection',
            hintText: isSpanish 
                ? 'Hoy me sentí... porque...'
                : 'Today I felt... because...',
            controller: _reflectionController,
            maxLines: 6,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return isSpanish ? 'Por favor escribe tu reflexión' : 'Please write your reflection';
              }
              if (value.trim().length < 10) {
                return isSpanish ? 'Escribe al menos 10 caracteres' : 'Write at least 10 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.blue[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isSpanish 
                        ? 'Tip: Sé honesto contigo mismo. No hay respuestas correctas o incorrectas.'
                        : 'Tip: Be honest with yourself. There are no right or wrong answers.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, delay: 200.ms);
  }

  Widget _buildGratitudeStep(bool isSpanish) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🙏', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            isSpanish ? 'Practica la gratitud' : 'Practice gratitude',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4facfe),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isSpanish 
                ? '¿Por qué estás agradecido hoy? Puede ser algo pequeño o grande'
                : 'What are you grateful for today? It can be something small or big',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CustomInput(
            labelText: isSpanish ? 'Estoy agradecido por...' : 'I\'m grateful for...',
            hintText: isSpanish 
                ? 'Hoy estoy agradecido por...'
                : 'Today I\'m grateful for...',
            controller: _gratitudeController,
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return isSpanish ? 'Por favor escribe algo por lo que estés agradecido' : 'Please write something you\'re grateful for';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.favorite, color: Colors.green[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isSpanish 
                        ? 'La gratitud mejora tu bienestar mental y te ayuda a enfocarte en lo positivo.'
                        : 'Gratitude improves your mental wellbeing and helps you focus on the positive.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, delay: 200.ms);
  }

  Widget _buildGoalStep(bool isSpanish) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🎯', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            isSpanish ? 'Meta para mañana' : 'Goal for tomorrow',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4facfe),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isSpanish 
                ? '¿Qué pequeña acción puedes hacer mañana para cuidar tu bienestar?'
                : 'What small action can you take tomorrow to care for your wellbeing?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          CustomInput(
            labelText: isSpanish ? 'Mi meta para mañana' : 'My goal for tomorrow',
            hintText: isSpanish 
                ? 'Mañana voy a...'
                : 'Tomorrow I will...',
            controller: _goalController,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return isSpanish ? 'Por favor escribe una meta para mañana' : 'Please write a goal for tomorrow';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.purple[600], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isSpanish 
                        ? 'Las metas pequeñas y alcanzables son más efectivas que las grandes y difíciles.'
                        : 'Small, achievable goals are more effective than big, difficult ones.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.purple[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, delay: 200.ms);
  }
}
