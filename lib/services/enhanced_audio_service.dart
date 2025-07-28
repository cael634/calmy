import 'package:flutter/services.dart';
import 'dart:async';

class EnhancedAudioService {
  static Timer? _soundTimer;
  static bool _isPlaying = false;
  static String? _currentSound;
  
  static bool get isPlaying => _isPlaying;
  static String? get currentSound => _currentSound;
  
  // Tipos de sonido disponibles
  static const String soundNone = 'none';
  static const String soundRelaxing = 'relaxing';
  static const String soundWhiteNoise = 'white_noise';
  
  static Future<void> playSound(String soundType) async {
    try {
      if (soundType == soundNone) {
        await stopSound();
        return;
      }
      
      if (_isPlaying && _currentSound == soundType) {
        return; // Ya está reproduciendo este sonido
      }
      
      await stopSound(); // Detener cualquier sonido actual
      
      _isPlaying = true;
      _currentSound = soundType;
      
      // Iniciar patrón de sonido/vibración basado en el tipo
      _startSoundPattern(soundType);
      
      print('Playing enhanced sound: $soundType');
      
    } catch (e) {
      print('Error playing enhanced sound: $e');
      _isPlaying = false;
      _currentSound = null;
    }
  }
  
  static void _startSoundPattern(String soundType) {
    switch (soundType) {
      case soundRelaxing:
        // Patrón relajante: sonido suave cada 4 segundos
        _soundTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
          if (_isPlaying) {
            SystemSound.play(SystemSoundType.click);
            // Vibración suave opcional
            HapticFeedback.lightImpact();
          } else {
            timer.cancel();
          }
        });
        break;
        
      case soundWhiteNoise:
        // Patrón de ruido blanco: sonidos más frecuentes
        _soundTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
          if (_isPlaying) {
            SystemSound.play(SystemSoundType.click);
            // Vibración muy suave para simular ruido blanco
            HapticFeedback.selectionClick();
          } else {
            timer.cancel();
          }
        });
        break;
    }
  }
  
  static Future<void> stopSound() async {
    try {
      _soundTimer?.cancel();
      _soundTimer = null;
      _isPlaying = false;
      _currentSound = null;
      print('Enhanced sound stopped');
    } catch (e) {
      print('Error stopping enhanced sound: $e');
      _isPlaying = false;
      _currentSound = null;
    }
  }
  
  static Future<void> pauseSound() async {
    try {
      _soundTimer?.cancel();
      print('Enhanced sound paused');
    } catch (e) {
      print('Error pausing enhanced sound: $e');
    }
  }
  
  static Future<void> resumeSound() async {
    try {
      if (_currentSound != null && _currentSound != soundNone) {
        _startSoundPattern(_currentSound!);
        print('Enhanced sound resumed: $_currentSound');
      }
    } catch (e) {
      print('Error resuming enhanced sound: $e');
    }
  }
  
  static Future<void> dispose() async {
    await stopSound();
  }
  
  static String getSoundName(String soundType, bool isSpanish) {
    switch (soundType) {
      case soundNone:
        return isSpanish ? 'Sin sonido' : 'No sound';
      case soundRelaxing:
        return isSpanish ? 'Tonos relajantes' : 'Relaxing tones';
      case soundWhiteNoise:
        return isSpanish ? 'Sonidos de concentración' : 'Focus sounds';
      default:
        return isSpanish ? 'Sin sonido' : 'No sound';
    }
  }
  
  static String getSoundDescription(String soundType, bool isSpanish) {
    switch (soundType) {
      case soundNone:
        return isSpanish ? 'Silencio total para concentrarte' : 'Complete silence to focus';
      case soundRelaxing:
        return isSpanish ? 'Tonos suaves cada pocos segundos' : 'Gentle tones every few seconds';
      case soundWhiteNoise:
        return isSpanish ? 'Sonidos regulares para concentración' : 'Regular sounds for concentration';
      default:
        return '';
    }
  }
  
  static String getSoundIcon(String soundType) {
    switch (soundType) {
      case soundNone:
        return '🔇';
      case soundRelaxing:
        return '🎵';
      case soundWhiteNoise:
        return '🌊';
      default:
        return '🔇';
    }
  }
}
