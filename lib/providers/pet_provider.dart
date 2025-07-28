import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PetConfig {
  String name;
  String type;
  String color;
  String aura;
  String hat;
  String clothes;
  String glasses;

  PetConfig({
    this.name = 'Calmi',
    this.type = 'cat',
    this.color = '#FF6B6B',
    this.aura = 'sparkles',
    this.hat = 'none',
    this.clothes = 'none',
    this.glasses = 'none',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'color': color,
      'aura': aura,
      'hat': hat,
      'clothes': clothes,
      'glasses': glasses,
    };
  }

  factory PetConfig.fromJson(Map<String, dynamic> json) {
    return PetConfig(
      name: json['name'] ?? 'Calmi',
      type: json['type'] ?? 'cat',
      color: json['color'] ?? '#FF6B6B',
      aura: json['aura'] ?? 'sparkles',
      hat: json['hat'] ?? 'none',
      clothes: json['clothes'] ?? 'none',
      glasses: json['glasses'] ?? 'none',
    );
  }

  // Getter para acceder directamente a la mascota
  String get pet => type;
}

class PetProvider extends ChangeNotifier {
  PetConfig _config = PetConfig();

  PetProvider() {
    _init();
  }

  Future<void> _init() async {
    await loadConfig();
  }

  PetConfig get config => _config;

  // Getter directo para la mascota
  String get pet => _config.pet;

  // Método para guardar la configuración completa
  Future<void> saveConfig(PetConfig newConfig) async {
    _config = newConfig;
    await _saveConfig();
    notifyListeners();
  }

  // Método para actualizar la mascota
  Future<void> updatePet(String newPetType) async {
    _config.type = newPetType;
    await _saveConfig();
    notifyListeners();
  }

  // Emoji mappings (versión optimizada)
  static const Map<String, String> _petEmojis = {
    'cat': '🐱',
    'dog': '🐶',
    'rabbit': '🐰',
    'fox': '🦊',
    'panda': '🐼',
    'bear': '🐻',
    'koala': '🐨',
    'lion': '🦁',
    'tiger': '🐯',
    'unicorn': '🦄',
    'alien': '👽',
    'monster': '👾',
    'pumpkin': '🎃',
    'robot': '🤖',
    'ghost': '👻',
    'monkey_speak': '🙊',
    'monkey_hear': '🙉',
    'monkey_see': '🙈',
    'monkey': '🐵',
    'frog': '🐸',
    'pig': '🐷',
    'cow': '🐮',
    'polar_bear': '🐻‍❄️',
    'horse': '🐴',
    'boar': '🐗',
    'wolf': '🐺',
    'moose': '🫎',
    'octopus': '🐙',
    'squid': '🦑',
    'crab': '🦀',
    'turtle': '🐢',
    'snake': '🐍',
    'whale': '🐋',
  };

  static const Map<String, String> _auraEmojis = {
    'sparkles': '✨',
    'hearts': '💕',
    'stars': '⭐',
    'rainbow': '🌈',
    'fire': '🔥',
    'lightning': '⚡',
    'magic': '🪄',
    'heart_fire': '❤️‍🔥',
    'heart_heal': '❤️‍🩹',
    'heart_exclamation': '❣️',
    'revolving_hearts': '💞',
    'beating_heart': '💓',
    'growing_heart': '💗',
    'sparkling_heart': '💖',
    'heart_arrow': '💘',
    'heart_gift': '💝',
    'heart_decoration': '💟',
    'violin': '🎻',
    'maracas': '🪇',
    'puzzle': '🧩',
    'trumpet': '🎺',
    'accordion': '🪗',
    'guitar': '🎸',
    'banjo': '🪕',
    'gamepad': '🎮',
    'microphone': '🎤',
    'coin': '🫟',
    'film_projector': '📽️',
    'movie_camera': '🎥',
    'camera_flash': '📸',
    'camera': '📷',
    'pager': '📟',
    'none': '',
  };

  static const Map<String, String> _hatEmojis = {
    'cap': '🧢',
    'crown': '👑',
    'top_hat': '🎩',
    'womans_hat': '👒',
    'graduation_cap': '🎓',
    'rescue_helmet': '⛑️',
    'headphones': '🎧',
    'none': '',
  };

  static const Map<String, String> _glassesEmojis = {
    'glasses': '👓',
    'sunglasses': '🕶️',
    'goggles': '🥽',
    'none': '',
  };

  static const Map<String, String> _clothesEmojis = {
    'scarf': '🧣',
    'bow': '🎀',
    'tie': '👔',
    'necklace': '📿',
    'medal': '🏅',
    'armor': '🛡️',
    'wings': '🪶',
    'stethoscope': '🩺',
    'fan': '🪭',
    'rosette': '🏵️',
    'military_medal': '🎖️',
    'gold_medal': '🥇',
    'reminder_ribbon': '🎗️',
    'none': '',
  };

  // Métodos optimizados para obtener emojis
  String getPetEmoji() => _petEmojis[_config.type] ?? '🐱';
  String getAuraEmoji() => _auraEmojis[_config.aura] ?? '';
  String getHatEmoji() => _hatEmojis[_config.hat] ?? '';
  String getGlassesEmoji() => _glassesEmojis[_config.glasses] ?? '';
  String getClothesEmoji() => _clothesEmojis[_config.clothes] ?? '';

  // Métodos de actualización optimizados
  Future<void> updateName(String name) async {
    _config.name = name;
    await _saveConfig();
    notifyListeners();
  }

  Future<void> updateColor(String color) async {
    _config.color = color;
    await _saveConfig();
    notifyListeners();
  }

  Future<void> updateAura(String aura) async {
    _config.aura = aura;
    await _saveConfig();
    notifyListeners();
  }

  Future<void> updateHat(String hat) async {
    _config.hat = hat;
    await _saveConfig();
    notifyListeners();
  }

  Future<void> updateGlasses(String glasses) async {
    _config.glasses = glasses;
    await _saveConfig();
    notifyListeners();
  }

  Future<void> updateClothes(String clothes) async {
    _config.clothes = clothes;
    await _saveConfig();
    notifyListeners();
  }

  // Persistencia
  Future<void> _saveConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = _config.toJson();
      for (final entry in configJson.entries) {
        await prefs.setString('pet_${entry.key}', entry.value.toString());
      }
    } catch (e) {
      debugPrint('Error saving pet config: $e');
    }
  }

  Future<void> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _config = PetConfig(
        name: prefs.getString('pet_name') ?? 'Calmi',
        type: prefs.getString('pet_type') ?? 'cat',
        color: prefs.getString('pet_color') ?? '#FF6B6B',
        aura: prefs.getString('pet_aura') ?? 'sparkles',
        hat: prefs.getString('pet_hat') ?? 'none',
        clothes: prefs.getString('pet_clothes') ?? 'none',
        glasses: prefs.getString('pet_glasses') ?? 'none',
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading pet config: $e');
    }
  }

  // Método para resetear a valores por defecto
  Future<void> resetToDefault() async {
    _config = PetConfig();
    await _saveConfig();
    notifyListeners();
  }
}