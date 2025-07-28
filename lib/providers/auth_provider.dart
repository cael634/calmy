import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _user = _auth.currentUser;
    _isLoading = false;
    
    _auth.authStateChanges().listen((User? user) {
      print('Auth state changed: ${user?.email}');
      _user = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      print('Attempting to sign in with: $email');
      
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print('Sign in successful: ${result.user?.email}');
      
      _user = result.user;
      _isLoading = false;
      notifyListeners();
      return true;
      
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      print('General error: $e');
      _isLoading = false;
      _errorMessage = 'Error inesperado. Verifica tu conexión a internet.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      print('Attempting to sign in with Google');
      
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential result = await _auth.signInWithCredential(credential);
      
      print('Google sign in successful: ${result.user?.email}');
      
      _user = result.user;

      // Check if this is a new user and create profile
      if (result.additionalUserInfo?.isNewUser == true && _user != null) {
        await _createUserProfile(_user!, _user!.displayName ?? 'Usuario');
        print('New Google user profile created');
      } else if (_user != null) {
        // Update last login for existing users
        await _database.child('users').child(_user!.uid).update({
          'lastLogin': ServerValue.timestamp,
        });
      }

      _isLoading = false;
      notifyListeners();
      return true;
      
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during Google sign in: ${e.code} - ${e.message}');
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      print('General error during Google sign in: $e');
      _isLoading = false;
      _errorMessage = 'Error al iniciar sesión con Google. Inténtalo de nuevo.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword(
    String email, 
    String password, 
    String name
  ) async {
    try {
      print('Attempting to create user with: $email');
      
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Validaciones básicas
      if (email.trim().isEmpty || password.isEmpty || name.trim().isEmpty) {
        throw Exception('Todos los campos son obligatorios');
      }

      if (password.length < 6) {
        throw Exception('La contraseña debe tener al menos 6 caracteres');
      }

      if (!email.contains('@')) {
        throw Exception('Email no válido');
      }

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      print('User created successfully: ${result.user?.email}');

      _user = result.user;

      if (_user != null) {
        try {
          await _user!.updateDisplayName(name.trim());
          await _user!.reload();
          _user = _auth.currentUser;
          
          await _createUserProfile(_user!, name.trim());
          print('User profile created in database');
        } catch (profileError) {
          print('Error updating profile: $profileError');
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
      
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during registration: ${e.code} - ${e.message}');
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      print('General error during registration: $e');
      _isLoading = false;
      _errorMessage = e.toString().contains('Exception:') 
          ? e.toString().replaceAll('Exception: ', '')
          : 'Error inesperado. Verifica tu conexión a internet.';
      notifyListeners();
      return false;
    }
  }

  Future<void> _createUserProfile(User user, String name) async {
    try {
      // Check if user profile already exists
      final snapshot = await _database.child('users').child(user.uid).get();
      
      if (!snapshot.exists) {
        final userData = {
          'name': name,
          'email': user.email,
          'level': 1,
          'experience': 0,
          'streak': 0,
          'sessionsToday': 0,
          'totalSessions': 0,
          'dailyGoal': 5,
          'achievements': [],
          'exerciseStats': {},
          'petConfig': {
            'name': 'Calmi',
            'type': 'cat',
            'color': '#FF6B6B',
            'aura': 'sparkles',
            'hat': 'none',
            'clothes': 'none',
            'glasses': 'none',
          },
          'createdAt': ServerValue.timestamp,
          'lastLogin': ServerValue.timestamp,
        };

        await _database.child('users').child(user.uid).set(userData);
        print('User data saved to database successfully');
      } else {
        // Update last login for existing users
        await _database.child('users').child(user.uid).update({
          'lastLogin': ServerValue.timestamp,
        });
        print('Updated last login for existing user');
      }
      
    } catch (e) {
      print('Error creating/updating user profile in database: $e');
    }
  }

  Future<void> signOut() async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();
      // Sign out from Firebase
      await _auth.signOut();
      
      _user = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }

  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No se encontró una cuenta con este email.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este email.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'El formato del email no es válido.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Inténtalo más tarde.';
      case 'operation-not-allowed':
        return 'El registro con email/contraseña no está habilitado en Firebase Console.';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet.';
      case 'invalid-credential':
        return 'Las credenciales proporcionadas no son válidas.';
      case 'account-exists-with-different-credential':
        return 'Ya existe una cuenta con este email usando un método diferente.';
      case 'popup-closed-by-user':
        return 'Inicio de sesión cancelado por el usuario.';
      default:
        return 'Error de autenticación: $errorCode. Verifica la configuración.';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
