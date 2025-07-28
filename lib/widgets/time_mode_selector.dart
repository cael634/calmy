import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/time_mode_provider.dart';
import '../providers/language_provider.dart';

class TimeModeSelector extends StatelessWidget {
  const TimeModeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<TimeModeProvider, LanguageProvider>(
      builder: (context, timeModeProvider, languageProvider, child) {
        final isSpanish = languageProvider.isSpanish;
        
        return Column(
          children: [
            // Selector de modo
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón de modo automático
                  _buildAutoModeButton(context, timeModeProvider, isSpanish),
                  const SizedBox(width: 4),
                  // Botones de modo manual
                  _buildModeButton(
                    context,
                    timeModeProvider,
                    TimeMode.morning,
                    Icons.wb_sunny,
                    isSpanish ? 'Mañana' : 'Morning',
                  ),
                  _buildModeButton(
                    context,
                    timeModeProvider,
                    TimeMode.afternoon,
                    Icons.wb_sunny_outlined,
                    isSpanish ? 'Tarde' : 'Afternoon',
                  ),
                  _buildModeButton(
                    context,
                    timeModeProvider,
                    TimeMode.night,
                    Icons.nightlight_round,
                    isSpanish ? 'Noche' : 'Night',
                  ),
                ],
              ),
            ).animate().slideY(begin: -0.3, delay: 200.ms),
            
            // Información de estado
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    timeModeProvider.isAutoMode ? Icons.schedule : Icons.touch_app,
                    color: Colors.white.withOpacity(0.8),
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeModeProvider.getStatusInfo(isSpanish),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (timeModeProvider.isAutoMode) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => timeModeProvider.forceAutoUpdate(),
                      child: Icon(
                        Icons.refresh,
                        color: Colors.white.withOpacity(0.8),
                        size: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
          ],
        );
      },
    );
  }

  Widget _buildAutoModeButton(
    BuildContext context,
    TimeModeProvider provider,
    bool isSpanish,
  ) {
    final isSelected = provider.isAutoMode;

    return GestureDetector(
      onTap: () {
        if (isSelected) {
          provider.disableAutoMode();
        } else {
          provider.enableAutoMode();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withOpacity(0.9) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected 
              ? null 
              : Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule,
              color: isSelected 
                  ? provider.primaryColor 
                  : Colors.white.withOpacity(0.7),
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              isSpanish ? 'Auto' : 'Auto',
              style: TextStyle(
                color: isSelected 
                    ? provider.primaryColor 
                    : Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    TimeModeProvider provider,
    TimeMode mode,
    IconData icon,
    String tooltip,
  ) {
    final isSelected = !provider.isAutoMode && provider.currentMode == mode;
    final isDisabled = provider.isAutoMode;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: isDisabled ? null : () => provider.setTimeMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.white.withOpacity(0.9) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: isSelected 
                ? provider.primaryColor 
                : Colors.white.withOpacity(isDisabled ? 0.3 : 0.7),
            size: 20,
          ),
        ),
      ),
    );
  }
}
