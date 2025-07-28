import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class SoundSelector extends StatelessWidget {
  final String selectedSound;
  final Function(String) onSoundChanged;
  final bool isSpanish;

  const SoundSelector({
    super.key,
    required this.selectedSound,
    required this.onSoundChanged,
    required this.isSpanish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.volume_up, color: Colors.purple, size: 24),
              const SizedBox(width: 8),
              Text(
                isSpanish ? 'Sonido de fondo' : 'Background sound',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isSpanish
                ? 'Elige un sonido para acompañar tu sesión'
                : 'Choose a sound for your session',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Opciones de sonido
          _buildSoundOption('none', isSpanish),
          const SizedBox(height: 12),
          _buildSoundOption('relaxing', isSpanish),
          const SizedBox(height: 12),
          _buildSoundOption('white_noise', isSpanish),

          // Estado del audio
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AudioService.getAudioStatus(isSpanish),
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
    );
  }

  Widget _buildSoundOption(String soundType, bool isSpanish) {
    final isSelected = selectedSound == soundType;

    return GestureDetector(
      onTap: () => onSoundChanged(soundType),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.purple.withOpacity(0.1)
              : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.purple
                : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.purple.withOpacity(0.2)
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  AudioService.getSoundIcon(soundType),
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AudioService.getSoundName(soundType, isSpanish),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.purple[700] : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AudioService.getSoundDescription(soundType, isSpanish),
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.purple[600] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
