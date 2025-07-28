import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class AudioHandler {
  static final AudioPlayer _justAudioPlayer = AudioPlayer();
  static FlutterSoundPlayer? _flutterSoundPlayer;
  static bool _useFallback = false;
  static String? _currentSound;

  // Constantes de tipo de sonido
  static const String soundNone = 'none';
  static const String soundRelaxing = 'relaxing';
  static const String soundWhiteNoise = 'white_noise';

  // Rutas de audio
  static const Map<String, String> _soundPaths = {
    soundRelaxing: 'assets/sounds/relaxing_nature.mp3',
    soundWhiteNoise: 'assets/sounds/white_noise.mp3',
  };

  static Future<void> initialize() async {
    try {
      _flutterSoundPlayer = FlutterSoundPlayer();
      await _flutterSoundPlayer?.openPlayer();
      await _flutterSoundPlayer?.setSubscriptionDuration(const Duration(milliseconds: 10));
    } catch (e) {
      print('Error initializing FlutterSound: $e');
    }
  }

  static Future<void> playSound(String soundType) async {
    if (soundType == soundNone) {
      await stopSound();
      return;
    }

    if (_currentSound == soundType) return;

    await stopSound();
    _currentSound = soundType;

    try {
      await _playWithJustAudio(soundType);
      _useFallback = false;
    } catch (e) {
      print('JustAudio failed: $e');
      await _playWithFlutterSound(soundType);
      _useFallback = true;
    }
  }

  static Future<void> _playWithJustAudio(String soundType) async {
    final path = _soundPaths[soundType];
    if (path == null) throw Exception('Sound path not found');

    // Solución alternativa para Xiaomi
    final file = await _copyAssetToLocal(path);
    await _justAudioPlayer.setFilePath(file.path);

    await _justAudioPlayer.setLoopMode(LoopMode.all);
    await _justAudioPlayer.setVolume(0.3);
    await _justAudioPlayer.play();
  }

  static Future<File> _copyAssetToLocal(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${assetPath.split('/').last}');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }

  static Future<void> _playWithFlutterSound(String soundType) async {
    if (_flutterSoundPlayer == null) {
      await initialize();
    }

    final path = _soundPaths[soundType];
    if (path == null) throw Exception('Sound path not found');

    try {
      if (!(_flutterSoundPlayer?.isStopped ?? true)) {
        await _flutterSoundPlayer?.stopPlayer();
      }

      final file = await _copyAssetToLocal(path);
      await _flutterSoundPlayer?.startPlayer(
        fromURI: file.path,
        codec: Codec.mp3,
        whenFinished: () {},
      );
    } catch (e) {
      print('FlutterSound playback error: $e');
      // Fallback a sonido del sistema
      await SystemSound.play(SystemSoundType.click);
    }
  }

  static Future<void> stopSound() async {
    try {
      await _justAudioPlayer.stop();
    } catch (e) {
      print('Error stopping JustAudio: $e');
    }
    try {
      await _flutterSoundPlayer?.stopPlayer();
    } catch (e) {
      print('Error stopping FlutterSound: $e');
    }
    _currentSound = null;
  }

  static Future<void> dispose() async {
    await _justAudioPlayer.dispose();
    try {
      await _flutterSoundPlayer?.closePlayer();
    } catch (e) {
      print('Error closing FlutterSound: $e');
    }
    _flutterSoundPlayer = null;
  }

  static bool get useFallback => _useFallback;
  static String? get currentSound => _currentSound;
}
