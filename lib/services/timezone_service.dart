import 'dart:convert';
import 'package:http/http.dart' as http;
import '../providers/time_mode_provider.dart';

class TimezoneService {
  static const String _ipApiUrl = 'http://ip-api.com/json/';
  static const String _worldTimeApiUrl = 'http://worldtimeapi.org/api/timezone/';
  
  /// Obtiene la zona horaria del usuario basada en su IP
  static Future<String?> getUserTimezone() async {
    try {
      // Primero obtenemos la información de ubicación basada en IP
      final response = await http.get(
        Uri.parse(_ipApiUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['timezone'] as String?;
        }
      }
    } catch (e) {
      print('Error getting timezone from IP: $e');
    }
    return null;
  }

  /// Obtiene la hora actual en la zona horaria especificada
  static Future<DateTime?> getCurrentTimeInTimezone(String timezone) async {
    try {
      final response = await http.get(
        Uri.parse('$_worldTimeApiUrl$timezone'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final dateTimeString = data['datetime'] as String;
        return DateTime.parse(dateTimeString);
      }
    } catch (e) {
      print('Error getting time for timezone $timezone: $e');
    }
    return null;
  }

  /// Determina el modo de tiempo basado en la hora
  static TimeMode getTimeModeFromHour(int hour) {
    if (hour >= 6 && hour < 17) {
      return TimeMode.morning; // 6:00 AM - 4:59 PM
    } else if (hour >= 17 && hour < 19) {
      return TimeMode.afternoon; // 5:00 PM - 6:59 PM
    } else {
      return TimeMode.night; // 7:00 PM - 5:59 AM
    }
  }

  /// Obtiene el modo de tiempo automático basado en la ubicación del usuario
  static Future<TimeMode> getAutoTimeMode() async {
    try {
      // Intentar obtener la zona horaria del usuario
      final timezone = await getUserTimezone();
      
      if (timezone != null) {
        // Obtener la hora actual en esa zona horaria
        final currentTime = await getCurrentTimeInTimezone(timezone);
        
        if (currentTime != null) {
          print('Current time in $timezone: $currentTime');
          return getTimeModeFromHour(currentTime.hour);
        }
      }
      
      // Fallback: usar hora local del dispositivo
      final localTime = DateTime.now();
      print('Using local device time: $localTime');
      return getTimeModeFromHour(localTime.hour);
      
    } catch (e) {
      print('Error in getAutoTimeMode: $e');
      // Fallback final: usar hora local
      final localTime = DateTime.now();
      return getTimeModeFromHour(localTime.hour);
    }
  }

  /// Obtiene información detallada de la ubicación y tiempo
  static Future<Map<String, dynamic>?> getLocationInfo() async {
    try {
      final timezone = await getUserTimezone();
      if (timezone == null) return null;

      final currentTime = await getCurrentTimeInTimezone(timezone);
      if (currentTime == null) return null;

      final timeMode = getTimeModeFromHour(currentTime.hour);

      return {
        'timezone': timezone,
        'currentTime': currentTime,
        'timeMode': timeMode,
        'hour': currentTime.hour,
        'minute': currentTime.minute,
      };
    } catch (e) {
      print('Error getting location info: $e');
      return null;
    }
  }

  /// Verifica si es necesario actualizar el modo de tiempo
  static bool shouldUpdateTimeMode(TimeMode currentMode, int currentHour) {
    final expectedMode = getTimeModeFromHour(currentHour);
    return currentMode != expectedMode;
  }

  /// Obtiene el nombre de la zona horaria en formato legible
  static String getReadableTimezone(String timezone) {
    // Convertir "America/New_York" a "America/New York"
    return timezone.replaceAll('_', ' ');
  }

  /// Obtiene el saludo apropiado basado en la hora
  static String getTimeBasedGreeting(int hour, bool isSpanish) {
    if (hour >= 6 && hour < 12) {
      return isSpanish ? 'Buenos días' : 'Good morning';
    } else if (hour >= 12 && hour < 17) {
      return isSpanish ? 'Buenas tardes' : 'Good afternoon';
    } else if (hour >= 17 && hour < 21) {
      return isSpanish ? 'Buenas tardes' : 'Good evening';
    } else {
      return isSpanish ? 'Buenas noches' : 'Good night';
    }
  }
}
