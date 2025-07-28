import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/timezone_service.dart';
import 'dart:async';

enum TimeMode {
  morning,
  afternoon,
  night,
}

class TimeModeProvider extends ChangeNotifier {
  TimeMode _currentMode = TimeMode.morning;
  bool _isAutoMode = true;
  Timer? _autoUpdateTimer;
  String? _userTimezone;
  DateTime? _lastUpdate;

  TimeMode get currentMode => _currentMode;
  bool get isAutoMode => _isAutoMode;
  String? get userTimezone => _userTimezone;
  DateTime? get lastUpdate => _lastUpdate;

  TimeModeProvider() {
    _loadTimeMode();
    _initializeAutoMode();
  }

  @override
  void dispose() {
    _autoUpdateTimer?.cancel();
    super.dispose();
  }

  /// Inicializa el modo automático
  void _initializeAutoMode() async {
    if (_isAutoMode) {
      await _updateAutoTimeMode();
      _startAutoUpdateTimer();
    }
  }

  /// Inicia el timer para actualización automática cada 30 minutos
  void _startAutoUpdateTimer() {
    _autoUpdateTimer?.cancel();
    _autoUpdateTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      if (_isAutoMode) {
        _updateAutoTimeMode();
      }
    });
  }

  /// Actualiza el modo de tiempo automáticamente
  Future<void> _updateAutoTimeMode() async {
    try {
      final newMode = await TimezoneService.getAutoTimeMode();
      final locationInfo = await TimezoneService.getLocationInfo();
      
      if (locationInfo != null) {
        _userTimezone = locationInfo['timezone'];
        _lastUpdate = locationInfo['currentTime'];
      }

      if (newMode != _currentMode) {
        _currentMode = newMode;
        notifyListeners();
        _saveTimeMode();
        print('Auto-updated time mode to: $newMode');
      }
    } catch (e) {
      print('Error updating auto time mode: $e');
    }
  }

  /// Establece el modo de tiempo manualmente
  void setTimeMode(TimeMode mode) {
    _currentMode = mode;
    _isAutoMode = false;
    _autoUpdateTimer?.cancel();
    notifyListeners();
    _saveTimeMode();
  }

  /// Establece el modo (alias para compatibilidad)
  void setMode(TimeMode mode) {
    setTimeMode(mode);
  }

  /// Habilita el modo automático
  Future<void> enableAutoMode() async {
    _isAutoMode = true;
    await _updateAutoTimeMode();
    _startAutoUpdateTimer();
    _saveTimeMode();
    notifyListeners();
  }

  /// Deshabilita el modo automático
  void disableAutoMode() {
    _isAutoMode = false;
    _autoUpdateTimer?.cancel();
    _saveTimeMode();
    notifyListeners();
  }

  /// Fuerza una actualización manual del modo automático
  Future<void> forceAutoUpdate() async {
    if (_isAutoMode) {
      await _updateAutoTimeMode();
    }
  }

  // Get gradient colors based on time mode
  List<Color> get currentGradient {
    switch (_currentMode) {
      case TimeMode.morning:
        return [
          const Color(0xFFFFE082),
          const Color(0xFFFFB74D),
          const Color(0xFFFF8A65),
        ];
      case TimeMode.afternoon:
        return [
          const Color(0xFF81C784),
          const Color(0xFF4FC3F7),
          const Color(0xFF29B6F6),
        ];
      case TimeMode.night:
        return [
          const Color(0xFF7986CB),
          const Color(0xFF5C6BC0),
          const Color(0xFF3F51B5),
        ];
    }
  }

  // Get background decoration
  BoxDecoration get backgroundDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: currentGradient,
      ),
    );
  }

  // Get greeting message
  String get greetingMessage {
    switch (_currentMode) {
      case TimeMode.morning:
        return 'Buenos días';
      case TimeMode.afternoon:
        return 'Buenas tardes';
      case TimeMode.night:
        return 'Buenas noches';
    }
  }

  String getGreeting(bool isSpanish) {
    if (_isAutoMode && _lastUpdate != null) {
      // Usar saludo basado en la hora real
      return TimezoneService.getTimeBasedGreeting(_lastUpdate!.hour, isSpanish);
    }
    
    // Fallback a saludos por modo
    switch (_currentMode) {
      case TimeMode.morning:
        return isSpanish ? 'Buenos días, Calmi te saluda!' : 'Good morning, Calmi greets you!';
      case TimeMode.afternoon:
        return isSpanish ? 'Buenas tardes, Calmi te saluda!' : 'Good afternoon, Calmi greets you!';
      case TimeMode.night:
        return isSpanish ? 'Buenas noches, Calmi te saluda!' : 'Good night, Calmi greets you!';
    }
  }

  // Get decorative elements
  List<Widget> get decorativeElements {
    switch (_currentMode) {
      case TimeMode.morning:
        return [
          Positioned(
            top: 100,
            right: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wb_sunny,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: 20,
            child: Icon(
              Icons.cloud,
              color: Colors.white.withOpacity(0.6),
              size: 30,
            ),
          ),
        ];
      case TimeMode.afternoon:
        return [
          Positioned(
            top: 120,
            right: 40,
            child: Icon(
              Icons.wb_sunny_outlined,
              color: Colors.white.withOpacity(0.7),
              size: 50,
            ),
          ),
          Positioned(
            top: 180,
            left: 30,
            child: Icon(
              Icons.nature,
              color: Colors.white.withOpacity(0.6),
              size: 35,
            ),
          ),
        ];
      case TimeMode.night:
        return [
          Positioned(
            top: 100,
            right: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.nightlight_round,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: 20,
            child: Icon(
              Icons.star,
              color: Colors.white.withOpacity(0.8),
              size: 25,
            ),
          ),
          Positioned(
            top: 220,
            left: 50,
            child: Icon(
              Icons.star,
              color: Colors.white.withOpacity(0.6),
              size: 20,
            ),
          ),
        ];
    }
  }

  // Get primary color for the mode
  Color get primaryColor {
    switch (_currentMode) {
      case TimeMode.morning:
        return const Color(0xFFFF8A65);
      case TimeMode.afternoon:
        return const Color(0xFF29B6F6);
      case TimeMode.night:
        return const Color(0xFF3F51B5);
    }
  }

  // Get secondary color for the mode
  Color get secondaryColor {
    switch (_currentMode) {
      case TimeMode.morning:
        return const Color(0xFFFFE082);
      case TimeMode.afternoon:
        return const Color(0xFF81C784);
      case TimeMode.night:
        return const Color(0xFF7986CB);
    }
  }

  // Get progress bar colors
  List<Color> getProgressColors() {
    switch (_currentMode) {
      case TimeMode.morning:
        return [const Color(0xFF4CAF50), const Color(0xFF8BC34A)];
      case TimeMode.afternoon:
        return [const Color(0xFFFF9800), const Color(0xFFE91E63)];
      case TimeMode.night:
        return [const Color(0xFF9C27B0), const Color(0xFFE91E63)];
    }
  }

  /// Obtiene información de estado para mostrar al usuario
  String getStatusInfo(bool isSpanish) {
    if (_isAutoMode) {
      if (_userTimezone != null && _lastUpdate != null) {
        final readableTimezone = TimezoneService.getReadableTimezone(_userTimezone!);
        final timeString = '${_lastUpdate!.hour.toString().padLeft(2, '0')}:${_lastUpdate!.minute.toString().padLeft(2, '0')}';
        
        return isSpanish 
            ? 'Automático • $timeString ($readableTimezone)'
            : 'Auto • $timeString ($readableTimezone)';
      } else {
        return isSpanish ? 'Modo automático activado' : 'Auto mode enabled';
      }
    } else {
      return isSpanish ? 'Modo manual' : 'Manual mode';
    }
  }

  // Persistence methods
  Future<void> _saveTimeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('timeMode', _currentMode.toString());
      await prefs.setBool('isAutoMode', _isAutoMode);
      if (_userTimezone != null) {
        await prefs.setString('userTimezone', _userTimezone!);
      }
      if (_lastUpdate != null) {
        await prefs.setString('lastUpdate', _lastUpdate!.toIso8601String());
      }
    } catch (e) {
      print('Error saving time mode: $e');
    }
  }

  Future<void> _loadTimeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString('timeMode');
      _isAutoMode = prefs.getBool('isAutoMode') ?? true;
      _userTimezone = prefs.getString('userTimezone');
      
      final lastUpdateString = prefs.getString('lastUpdate');
      if (lastUpdateString != null) {
        _lastUpdate = DateTime.parse(lastUpdateString);
      }
      
      if (savedMode != null && !_isAutoMode) {
        switch (savedMode) {
          case 'TimeMode.morning':
            _currentMode = TimeMode.morning;
            break;
          case 'TimeMode.afternoon':
            _currentMode = TimeMode.afternoon;
            break;
          case 'TimeMode.night':
            _currentMode = TimeMode.night;
            break;
        }
      }
      notifyListeners();
    } catch (e) {
      print('Error loading time mode: $e');
    }
  }

  Future<void> loadMode() async {
    await _loadTimeMode();
  }
}
