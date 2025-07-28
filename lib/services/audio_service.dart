import 'audio_handler.dart'; // Asegúrate de importar AudioHandler

class AudioService {
  // Re-exportamos las constantes de AudioHandler
  static const String soundNone = AudioHandler.soundNone;
  static const String soundRelaxing = AudioHandler.soundRelaxing;
  static const String soundWhiteNoise = AudioHandler.soundWhiteNoise;

  static Future<void> init() async {
    await AudioHandler.initialize();
  }

  static Future<void> playSound(String soundType) async {
    await AudioHandler.playSound(soundType);
  }

  static Future<void> stopSound() async {
    await AudioHandler.stopSound();
  }

  static Future<void> dispose() async {
    await AudioHandler.dispose();
  }

  static bool get isPlaying => AudioHandler.currentSound != null &&
      AudioHandler.currentSound != soundNone;
  static String? get currentSound => AudioHandler.currentSound;
  static bool get useFallback => AudioHandler.useFallback;

  static String getSoundName(String soundType, bool isSpanish) {
    switch (soundType) {
      case soundNone: return isSpanish ? 'Sin sonido' : 'No sound';
      case soundRelaxing: return isSpanish ? 'Sonidos de naturaleza' : 'Nature sounds';
      case soundWhiteNoise: return isSpanish ? 'Ruido blanco' : 'White noise';
      default: return isSpanish ? 'Sin sonido' : 'No sound';
    }
  }

  static String getSoundDescription(String soundType, bool isSpanish) {
    String base = '';
    switch (soundType) {
      case soundNone: base = isSpanish ? 'Silencio total' : 'Complete silence';
      case soundRelaxing: base = isSpanish ? 'Sonidos naturales relajantes' : 'Relaxing nature sounds';
      case soundWhiteNoise: base = isSpanish ? 'Ruido blanco para concentración' : 'White noise for focus';
    }
    if (useFallback && soundType != soundNone) {
      base += isSpanish ? ' (modo compatible)' : ' (compatibility mode)';
    }
    return base;
  }

  static String getSoundIcon(String soundType) {
    switch (soundType) {
      case soundNone: return '🔇';
      case soundRelaxing: return useFallback ? '🌳' : '🌿';
      case soundWhiteNoise: return useFallback ? '📢' : '🌊';
      default: return '🔇';
    }
  }

  static String getAudioStatus(bool isSpanish) {
    return useFallback
        ? isSpanish ? 'Usando reproductor compatible' : 'Using compatible player'
        : isSpanish ? 'Reproduciendo normalmente' : 'Playing normally';
  }
}
