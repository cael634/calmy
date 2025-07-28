import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('es', 'ES');
  bool _isSpanish = true;

  Locale get currentLocale => _currentLocale;
  bool get isSpanish => _isSpanish;
  String get currentLanguage => _isSpanish ? 'es' : 'en';

  LanguageProvider() {
    _loadLanguage();
  }

  void setLanguage(String languageCode, String countryCode) {
    _currentLocale = Locale(languageCode, countryCode);
    _isSpanish = languageCode == 'es';
    notifyListeners();
    _saveLanguage();
  }

  void toggleLanguage() {
    _isSpanish = !_isSpanish;
    _currentLocale = _isSpanish ? const Locale('es', 'ES') : const Locale('en', 'US');
    notifyListeners();
    _saveLanguage();
  }

  Map<String, String> get texts {
    switch (_currentLocale.languageCode) {
      case 'es':
        return _spanishTexts;
      case 'en':
        return _englishTexts;
      default:
        return _spanishTexts;
    }
  }

  String getText(String key) {
    return texts[key] ?? key;
  }

  Future<void> _saveLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', _currentLocale.languageCode);
      await prefs.setString('country', _currentLocale.countryCode ?? '');
      await prefs.setBool('isSpanish', _isSpanish);
    } catch (e) {
      print('Error saving language: $e');
    }
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('language') ?? 'es';
      final country = prefs.getString('country') ?? 'ES';
      _isSpanish = prefs.getBool('isSpanish') ?? true;
      _currentLocale = Locale(language, country);
      notifyListeners();
    } catch (e) {
      print('Error loading language: $e');
    }
  }

  static const Map<String, String> _spanishTexts = {
    'app_name': 'Calmy',
    'welcome': 'Bienvenido',
    'good_morning': 'Buenos días',
    'good_afternoon': 'Buenas tardes',
    'good_evening': 'Buenas noches',
    'breathing_exercises': 'Ejercicios de Respiración',
    'mood_tracker': 'Seguimiento del Estado de Ánimo',
    'pet_customization': 'Personalizar Mascota',
    'achievements': 'Logros',
    'sleep_exercises': 'Ejercicios para Dormir',
    'emergency': 'Emergencia',
    'settings': 'Configuración',
    'profile': 'Perfil',
    'statistics': 'Estadísticas',
    'daily_goal': 'Meta Diaria',
    'streak': 'Racha',
    'level': 'Nivel',
    'experience': 'Experiencia',
    'completed_sessions': 'Sesiones Completadas',
    'start_exercise': 'Comenzar Ejercicio',
    'pause': 'Pausar',
    'resume': 'Continuar',
    'finish': 'Finalizar',
    'well_done': '¡Bien hecho!',
    'keep_going': '¡Sigue así!',
    'relax': 'Relájate',
    'breathe_in': 'Inhala',
    'breathe_out': 'Exhala',
    'hold': 'Mantén',
    'pet_name': 'Nombre de la Mascota',
    'pet_type': 'Tipo de Mascota',
    'pet_color': 'Color',
    'accessories': 'Accesorios',
    'save': 'Guardar',
    'cancel': 'Cancelar',
    'delete': 'Eliminar',
    'edit': 'Editar',
    'add': 'Agregar',
    'remove': 'Quitar',
    'close': 'Cerrar',
    'open': 'Abrir',
    'next': 'Siguiente',
    'previous': 'Anterior',
    'done': 'Hecho',
    'loading': 'Cargando...',
    'error': 'Error',
    'success': 'Éxito',
    'warning': 'Advertencia',
    'info': 'Información',
  };

  static const Map<String, String> _englishTexts = {
    'app_name': 'Calmy',
    'welcome': 'Welcome',
    'good_morning': 'Good morning',
    'good_afternoon': 'Good afternoon',
    'good_evening': 'Good evening',
    'breathing_exercises': 'Breathing Exercises',
    'mood_tracker': 'Mood Tracker',
    'pet_customization': 'Pet Customization',
    'achievements': 'Achievements',
    'sleep_exercises': 'Sleep Exercises',
    'emergency': 'Emergency',
    'settings': 'Settings',
    'profile': 'Profile',
    'statistics': 'Statistics',
    'daily_goal': 'Daily Goal',
    'streak': 'Streak',
    'level': 'Level',
    'experience': 'Experience',
    'completed_sessions': 'Completed Sessions',
    'start_exercise': 'Start Exercise',
    'pause': 'Pause',
    'resume': 'Resume',
    'finish': 'Finish',
    'well_done': 'Well done!',
    'keep_going': 'Keep going!',
    'relax': 'Relax',
    'breathe_in': 'Breathe in',
    'breathe_out': 'Breathe out',
    'hold': 'Hold',
    'pet_name': 'Pet Name',
    'pet_type': 'Pet Type',
    'pet_color': 'Color',
    'accessories': 'Accessories',
    'save': 'Save',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'edit': 'Edit',
    'add': 'Add',
    'remove': 'Remove',
    'close': 'Close',
    'open': 'Open',
    'next': 'Next',
    'previous': 'Previous',
    'done': 'Done',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'warning': 'Warning',
    'info': 'Information',
  };
}
