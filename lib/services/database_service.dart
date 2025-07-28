import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get currentUserId => _auth.currentUser?.uid;

  // User Data Methods
  static Future<Map<String, dynamic>?> getUserData() async {
    if (currentUserId == null) return null;
    
    try {
      final snapshot = await _database.child('users').child(currentUserId!).get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  static Future<void> updateUserData(Map<String, dynamic> data) async {
    if (currentUserId == null) return;
    
    try {
      await _database.child('users').child(currentUserId!).update(data);
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  // Specific update methods
  static Future<void> updateLevel(int level) async {
    await updateUserData({'level': level});
  }

  static Future<void> updateExperience(int experience) async {
    await updateUserData({'experience': experience});
  }

  static Future<void> updateStreak(int streak) async {
    await updateUserData({'streak': streak});
  }

  static Future<void> updateSessionsToday(int sessions) async {
    await updateUserData({'sessionsToday': sessions});
  }

  static Future<void> updateTotalSessions(int sessions) async {
    await updateUserData({'totalSessions': sessions});
  }

  static Future<void> updateAchievements(List<String> achievements) async {
    await updateUserData({'achievements': achievements});
  }

  static Future<void> updateExerciseStats(Map<String, int> stats) async {
    await updateUserData({'exerciseStats': stats});
  }

  static Future<void> updatePetConfig(Map<String, dynamic> petConfig) async {
    await updateUserData({'petConfig': petConfig});
  }

  static Future<void> updateLastLogin() async {
    await updateUserData({'lastLogin': ServerValue.timestamp});
  }

  // Listen to user data changes
  static Stream<Map<String, dynamic>?> getUserDataStream() {
    if (currentUserId == null) return Stream.value(null);
    
    return _database.child('users').child(currentUserId!).onValue.map((event) {
      if (event.snapshot.exists) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return null;
    });
  }
}
