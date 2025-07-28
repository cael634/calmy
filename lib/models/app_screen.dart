enum AppScreen {
  home,
  breathingBubble,
  breathingTriangle,
  moodTracker,
  petCustomization,
  achievements,
  sleepExercises,
  emergency,
  login,
  register,
  introduction,
}

extension AppScreenExtension on AppScreen {
  String get title {
    switch (this) {
      case AppScreen.home:
        return 'Inicio';
      case AppScreen.breathingBubble:
        return 'Respiración Burbuja';
      case AppScreen.breathingTriangle:
        return 'Respiración Triángulo';
      case AppScreen.moodTracker:
        return 'Estado de Ánimo';
      case AppScreen.petCustomization:
        return 'Personalizar Mascota';
      case AppScreen.achievements:
        return 'Logros';
      case AppScreen.sleepExercises:
        return 'Ejercicios para Dormir';
      case AppScreen.emergency:
        return 'Emergencia';
      case AppScreen.login:
        return 'Iniciar Sesión';
      case AppScreen.register:
        return 'Registrarse';
      case AppScreen.introduction:
        return 'Introducción';
    }
  }

  String get route {
    switch (this) {
      case AppScreen.home:
        return '/home';
      case AppScreen.breathingBubble:
        return '/breathing-bubble';
      case AppScreen.breathingTriangle:
        return '/breathing-triangle';
      case AppScreen.moodTracker:
        return '/mood-tracker';
      case AppScreen.petCustomization:
        return '/pet-customization';
      case AppScreen.achievements:
        return '/achievements';
      case AppScreen.sleepExercises:
        return '/sleep-exercises';
      case AppScreen.emergency:
        return '/emergency';
      case AppScreen.login:
        return '/login';
      case AppScreen.register:
        return '/register';
      case AppScreen.introduction:
        return '/introduction';
    }
  }
}
