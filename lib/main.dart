import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:calmy/providers/app_state.dart';
import 'providers/pet_provider.dart';
import 'providers/time_mode_provider.dart';
import 'providers/language_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/introduction_screen.dart';
import 'screens/breathing_exercise_screen.dart';
import 'screens/mood_tracker_screen.dart';
import 'screens/pet_customization_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/sleep_exercises_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'models/app_screen.dart' as models;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => PetProvider()),
        ChangeNotifierProvider(create: (_) => TimeModeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: Consumer2<LanguageProvider, AuthProvider>(
        builder: (context, languageProvider, authProvider, child) {
          return MaterialApp(
            title: 'Calmy',
            locale: languageProvider.currentLocale,
            theme: ThemeData(
              primarySwatch: Colors.purple,
              fontFamily: 'Poppins',
            ),
            home: WillPopScope(
              onWillPop: () async {
                final appState = Provider.of<AppState>(context, listen: false);

                if (appState.currentScreen != models.AppScreen.home &&
                    appState.currentScreen != models.AppScreen.introduction) {
                  appState.navigateToHome();
                  return false;
                }

                return true;
              },
              child: Consumer<AppState>(
                builder: (context, appState, child) {
                  // Check authentication state
                  if (authProvider.isLoading) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  // If not authenticated, show login/register flow
                  if (!authProvider.isAuthenticated) {
                    if (appState.isFirstTime) {
                      return const IntroductionScreen();
                    }
                    
                    switch (appState.currentScreen) {
                      case models.AppScreen.register:
                        return const RegisterScreen();
                      case models.AppScreen.login:
                      default:
                        return const LoginScreen();
                    }
                  }

                  // If authenticated, show main app
                  switch (appState.currentScreen) {
                    case models.AppScreen.home:
                      return const HomeScreen();
                    case models.AppScreen.breathingBubble:
                      return const BreathingExerciseScreen(exerciseType: 'bubble');
                    case models.AppScreen.breathingTriangle:
                      return const BreathingExerciseScreen(exerciseType: 'triangle');
                    case models.AppScreen.moodTracker:
                      return const MoodTrackerScreen();
                    case models.AppScreen.petCustomization:
                      return const PetCustomizationScreen();
                    case models.AppScreen.achievements:
                      return const AchievementsScreen();
                    case models.AppScreen.sleepExercises:
                      return const SleepExercisesScreen();
                    case models.AppScreen.emergency:
                      return const EmergencyScreen();
                    default:
                      return const HomeScreen();
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
