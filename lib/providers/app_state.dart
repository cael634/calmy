import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_screen.dart';
import '../services/database_service.dart';

class AppState extends ChangeNotifier {
  AppScreen _currentScreen = AppScreen.home;
  bool _isFirstTime = true;
  String _userName = '';
  int _level = 1;
  int _experience = 0;
  int _streak = 0;
  int _sessionsToday = 0;
  int _totalSessions = 0;
  int _dailyGoal = 5;
  List<String> _achievements = [];
  Map<String, int> _exerciseStats = {};
  String _userEmail = '';
  bool _isLoggedIn = false;
  bool _isLoading = false;

  // Getters para las nuevas propiedades
  String get userEmail => _userEmail;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  // Getters
  AppScreen get currentScreen => _currentScreen;
  bool get isFirstTime => _isFirstTime;
  String get userName => _userName;
  int get level => _level;
  int get userLevel => _level;
  int get experience => _experience;
  int get userXP => _experience;
  int get streak => _streak;
  int get streakDays => _streak;
  int get sessionsToday => _sessionsToday;
  int get completedSessions => _sessionsToday;
  int get totalSessions => _totalSessions;
  int get dailyGoal => _dailyGoal;
  List<String> get achievements => _achievements;
  Map<String, int> get exerciseStats => _exerciseStats;

  AppState() {
    loadState();
    _listenToUserDataChanges();
  }

  void _listenToUserDataChanges() {
    DatabaseService.getUserDataStream().listen((userData) {
      if (userData != null) {
        _updateFromFirebaseData(userData);
      }
    });
  }

  void _updateFromFirebaseData(Map<String, dynamic> data) {
    _userName = data['name'] ?? '';
    _level = data['level'] ?? 1;
    _experience = data['experience'] ?? 0;
    _streak = data['streak'] ?? 0;
    _sessionsToday = data['sessionsToday'] ?? 0;
    _totalSessions = data['totalSessions'] ?? 0;
    _dailyGoal = data['dailyGoal'] ?? 5;

    if (data['achievements'] != null) {
      _achievements = List<String>.from(data['achievements']);
    }

    if (data['exerciseStats'] != null) {
      _exerciseStats = Map<String, int>.from(data['exerciseStats']);
    }

    notifyListeners();
  }

  // Navigation methods
  void navigateToScreen(AppScreen screen) {
    _currentScreen = screen;
    notifyListeners();
  }

  void navigateTo(AppScreen screen) {
    _currentScreen = screen;
    notifyListeners();
  }

  void navigateToHome() {
    _currentScreen = AppScreen.home;
    notifyListeners();
  }

  // User data methods
  void setUserName(String name) {
    _userName = name;
    notifyListeners();
    DatabaseService.updateUserData({'name': name});
  }

  void completeFirstTimeSetup() {
    _isFirstTime = false;
    notifyListeners();
    _saveState();
  }

  Future<void> initializeNewUser(String name) async {
    _userName = name;
    _isFirstTime = false;
    notifyListeners();
    _saveState();
  }

  Future<void> loadUserDataFromFirebase() async {
    final userData = await DatabaseService.getUserData();
    if (userData != null) {
      _updateFromFirebaseData(userData);
      await DatabaseService.updateLastLogin();
    }
  }
  // Dentro de tu clase AppState existente
  Future<bool> login(String email, [String password = '']) async {
    try {
      // Implementación básica temporal
      _userEmail = email;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      _userEmail = email;
      _userName = name;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }



  void addXP(int xp) {
    _experience += xp;

    // Check for level up
    int newLevel = (_experience / 100).floor() + 1;
    if (newLevel > _level) {
      _level = newLevel;
      addAchievement('level_$newLevel');
      DatabaseService.updateLevel(_level);
    }

    DatabaseService.updateExperience(_experience);
    notifyListeners();
  }

  void addExperience(int xp) {
    addXP(xp);
  }

  void incrementStreak() {
    _streak++;

    // Add streak achievements
    if (_streak == 7) addAchievement('streak_7');
    if (_streak == 30) addAchievement('streak_30');
    if (_streak == 100) addAchievement('streak_100');

    DatabaseService.updateStreak(_streak);
    notifyListeners();
  }

  void resetStreak() {
    _streak = 0;
    DatabaseService.updateStreak(_streak);
    notifyListeners();
  }

  void completeSession(String exerciseType) {
    _sessionsToday++;
    _totalSessions++;

    // Update exercise stats
    _exerciseStats[exerciseType] = (_exerciseStats[exerciseType] ?? 0) + 1;

    // Add XP for completing session
    addXP(10);

    // Check for achievements
    _checkAndUnlockAchievements(exerciseType);

    // Check for daily goal achievement
    if (_sessionsToday >= _dailyGoal) {
      addAchievement('daily_goal_completed');
    }

    // Update Firebase
    DatabaseService.updateSessionsToday(_sessionsToday);
    DatabaseService.updateTotalSessions(_totalSessions);
    DatabaseService.updateExerciseStats(_exerciseStats);

    notifyListeners();
  }

  void _checkAndUnlockAchievements(String exerciseType) {
    // First session
    if (_totalSessions == 1) {
      addAchievement('first_session');
    }

    // Streak achievements
    if (_streak == 3) addAchievement('streak_3');
    if (_streak == 7) addAchievement('streak_7');
    if (_streak == 30) addAchievement('streak_30');

    // Exercise-specific achievements
    int breathingTotal = (_exerciseStats['bubble'] ?? 0) + (_exerciseStats['triangle'] ?? 0);
    if (breathingTotal == 10) addAchievement('breathing_master');

    if (_exerciseStats['mood_tracker'] == 5) addAchievement('mood_tracker_5');

    // Session milestones
    if (_totalSessions == 50) addAchievement('sessions_50');

    // Level achievements
    if (_level == 5) addAchievement('level_5');
    if (_level == 8) addAchievement('level_8');
    if (_level == 10) addAchievement('level_10');
    if (_level == 12) addAchievement('level_12');

    // Daily goal achievement
    if (_sessionsToday >= _dailyGoal) {
      addAchievement('daily_goal_${DateTime.now().day}');
    }
  }

  void incrementSessionsToday() {
    _sessionsToday++;
    DatabaseService.updateSessionsToday(_sessionsToday);
    notifyListeners();
  }

  void setDailyGoal(int goal) {
    _dailyGoal = goal;
    DatabaseService.updateUserData({'dailyGoal': goal});
    notifyListeners();
  }

  void addAchievement(String achievementId) {
    if (!_achievements.contains(achievementId)) {
      _achievements.add(achievementId);
      // Add bonus XP for unlocking achievement
      _experience += 25;
      DatabaseService.updateAchievements(_achievements);
      DatabaseService.updateExperience(_experience);
      notifyListeners();
    }
  }

  void unlockAchievement(String achievementId) {
    addAchievement(achievementId);
  }

  void resetDailyProgress() {
    _sessionsToday = 0;
    DatabaseService.updateSessionsToday(_sessionsToday);
    notifyListeners();
  }

  // Persistence methods (local backup)
  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', _isFirstTime);
    } catch (e) {
      print('Error saving app state: $e');
    }
  }


  Future<void> loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isFirstTime = prefs.getBool('isFirstTime') ?? true;
      notifyListeners();
    } catch (e) {
      print('Error loading app state: $e');
    }
  }

  // Helper methods
  double get progressToNextLevel {
    return (_experience % 100) / 100.0;
  }

  int get xpToNextLevel {
    return 100 - (_experience % 100);
  }

  bool hasAchievement(String achievementId) {
    return _achievements.contains(achievementId);
  }

  int getExerciseCount(String exerciseType) {
    return _exerciseStats[exerciseType] ?? 0;
  }

  double get dailyProgress {
    return _sessionsToday / _dailyGoal;
  }

  bool get isDailyGoalComplete {
    return _sessionsToday >= _dailyGoal;
  }
}
