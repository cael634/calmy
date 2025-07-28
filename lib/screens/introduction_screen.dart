import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:calmy/providers/app_state.dart' ;
import '../providers/language_provider.dart';
import '../widgets/gradient_background.dart';
import '../models/app_screen.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final appState = Provider.of<AppState>(context);
    final isSpanish = languageProvider.isSpanish;

    final pages = [
      _buildIntroPage(
        emoji: '🧘‍♀️',
        title: isSpanish ? 'Bienvenido a Calmi' : 'Welcome to Calmie',
        subtitle: isSpanish
            ? 'Tu compañero personal para el bienestar mental'
            : 'Your personal companion for mental wellness',
        description: isSpanish
            ? 'Descubre técnicas de respiración, reflexión y relajación que te ayudarán a encontrar tu paz interior.'
            : 'Discover breathing techniques, reflection, and relaxation that will help you find your inner peace.',
      ),
      _buildIntroPage(
        emoji: '🐱',
        title: isSpanish ? 'Tu Mascota Compañera' : 'Your Companion Pet',
        subtitle: isSpanish
            ? 'Crece junto a tu amigo virtual'
            : 'Grow together with your virtual friend',
        description: isSpanish
            ? 'Personaliza tu mascota, desbloquea accesorios únicos y ve cómo evoluciona mientras progresas en tu viaje de bienestar.'
            : 'Customize your pet, unlock unique accessories, and watch it evolve as you progress on your wellness journey.',
      ),
      _buildIntroPage(
        emoji: '🏆',
        title: isSpanish ? 'Logros y Progreso' : 'Achievements & Progress',
        subtitle: isSpanish
            ? 'Celebra cada paso de tu crecimiento'
            : 'Celebrate every step of your growth',
        description: isSpanish
            ? 'Gana experiencia, desbloquea logros y mantén tu racha diaria. Cada respiración cuenta para tu bienestar.'
            : 'Earn experience, unlock achievements, and maintain your daily streak. Every breath counts for your wellbeing.',
      ),
    ];

    return Scaffold(
      body: GradientBackground(
        colors: const [
          Color(0xFFE3F2FD),
          Color(0xFFF3E5F5),
          Color(0xFFFCE4EC),
        ],
        child: SafeArea(
          child: Column(
            children: [
              // Language selector
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => languageProvider.toggleLanguage(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isSpanish ? '🇪🇸 ES' : '🇺🇸 EN',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.language, size: 20),
                          ],
                        ),
                      ),
                    ).animate().slideX(begin: 0.3, delay: 200.ms),
                  ],
                ),
              ),

              // Page view
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: pages.length,
                  itemBuilder: (context, index) => pages[index],
                ),
              ),

              // Page indicators
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.purple
                            : Colors.purple.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      TextButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text(
                          isSpanish ? 'Anterior' : 'Previous',
                          style: TextStyle(
                            color: Colors.purple[600],
                            fontSize: 16,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 80),

                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage < pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          // Complete first time setup and navigate to login
                          appState.completeFirstTimeSetup();
                          appState.navigateTo(AppScreen.login);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 8,
                      ),
                      child: Text(
                        _currentPage < pages.length - 1
                            ? (isSpanish ? 'Siguiente' : 'Next')
                            : (isSpanish ? 'Comenzar' : 'Get Started'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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

  Widget _buildIntroPage({
    required String emoji,
    required String title,
    required String subtitle,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji with animation
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.8),
                  Colors.purple.withOpacity(0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 80),
              ),
            ),
          ).animate().scale(duration: 600.ms).then().shimmer(),

          const SizedBox(height: 40),

          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 18,
              color: Colors.purple[600],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 24),

          // Description
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
