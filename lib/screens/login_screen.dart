import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:calmy/providers/app_state.dart';
import 'package:calmy/providers/language_provider.dart';
import 'package:calmy/widgets/gradient_background.dart';
import 'package:calmy/widgets/google_sign_in_button.dart';
import 'package:calmy/widgets/custom_button.dart';
import 'package:calmy/widgets/custom_input.dart';
import 'package:calmy/models/app_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Verificar conexión a Internet
      final hasConnection = await _checkInternetConnection();
      if (!hasConnection) {
        _showErrorSnackbar(context.read<LanguageProvider>().isSpanish
            ? 'Sin conexión a Internet'
            : 'No internet connection');
        return;
      }

      // Autenticación con Firebase
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        final appState = context.read<AppState>();
        appState.login(_emailController.text);
        appState.navigateTo(AppScreen.home);

        _showSuccessSnackbar(context.read<LanguageProvider>().isSpanish
            ? 'Sesión iniciada correctamente'
            : 'Logged in successfully');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = context.read<LanguageProvider>().isSpanish
              ? 'Usuario no encontrado'
              : 'User not found';
          break;
        case 'wrong-password':
          errorMessage = context.read<LanguageProvider>().isSpanish
              ? 'Contraseña incorrecta'
              : 'Wrong password';
          break;
        case 'network-request-failed':
          errorMessage = context.read<LanguageProvider>().isSpanish
              ? 'Error de conexión con Firebase'
              : 'Firebase connection error';
          break;
        case 'too-many-requests':
          errorMessage = context.read<LanguageProvider>().isSpanish
              ? 'Demasiados intentos. Intenta más tarde'
              : 'Too many attempts. Try again later';
          break;
        default:
          errorMessage = context.read<LanguageProvider>().isSpanish
              ? 'Error al iniciar sesión'
              : 'Login error';
      }
      _showErrorSnackbar(errorMessage);
    } catch (e) {
      _showErrorSnackbar(context.read<LanguageProvider>().isSpanish
          ? 'Error inesperado'
          : 'Unexpected error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);

    try {
      // Verificar conexión a Internet
      final hasConnection = await _checkInternetConnection();
      if (!hasConnection) {
        _showErrorSnackbar(context.read<LanguageProvider>().isSpanish
            ? 'Sin conexión a Internet'
            : 'No internet connection');
        return;
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final appState = context.read<AppState>();
        appState.login(userCredential.user!.email ?? 'google_user@gmail.com');
        appState.navigateTo(AppScreen.home);

        _showSuccessSnackbar(context.read<LanguageProvider>().isSpanish
            ? 'Sesión con Google exitosa'
            : 'Google login successful');
      }
    } on FirebaseAuthException catch (e) {
      final errorMessage = e.code == 'network-request-failed'
          ? (context.read<LanguageProvider>().isSpanish
          ? 'Error de conexión con Firebase'
          : 'Firebase connection error')
          : (context.read<LanguageProvider>().isSpanish
          ? 'Error con Google Sign-In'
          : 'Google Sign-In error');

      _showErrorSnackbar(errorMessage);
    } catch (e) {
      _showErrorSnackbar(context.read<LanguageProvider>().isSpanish
          ? 'Error inesperado'
          : 'Unexpected error');
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSpanish = context.watch<LanguageProvider>().isSpanish;

    return Scaffold(
      body: GradientBackground(
        colors: const [
          Color(0xFF667eea),
          Color(0xFF764ba2),
          Color(0xFFf093fb),
        ],
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Connection status indicator
                StreamBuilder<bool>(
                  stream: InternetConnectionChecker().onStatusChange.map(
                        (status) => status == InternetConnectionStatus.connected,
                  ),
                  builder: (context, snapshot) {
                    final isConnected = snapshot.data ?? true;
                    return AnimatedContainer(
                      duration: 300.ms,
                      height: isConnected ? 0 : 40,
                      color: Colors.red,
                      child: Center(
                        child: Text(
                          isSpanish ? 'Sin conexión a Internet' : 'No internet connection',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),

                // Logo and welcome
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.8),
                            Colors.purple.withOpacity(0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🧘‍♀️', style: TextStyle(fontSize: 50)),
                      ),
                    ).animate().scale(duration: 600.ms).then().shimmer(),

                    const SizedBox(height: 24),

                    Text(
                      isSpanish ? 'Bienvenido a Calmi' : 'Welcome to Calmie',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 8),

                    Text(
                      isSpanish
                          ? 'Tu compañero para el bienestar mental'
                          : 'Your companion for mental wellness',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),

                const SizedBox(height: 40),

                // Login form
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSpanish ? 'Iniciar Sesión' : 'Sign In',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          isSpanish
                              ? 'Ingresa a tu cuenta para continuar'
                              : 'Enter your account to continue',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Email field
                        CustomInput(
                          labelText: isSpanish ? 'Correo electrónico' : 'Email',
                          hintText: isSpanish ? 'tu@email.com' : 'your@email.com',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return isSpanish ? 'Por favor ingresa tu email' : 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return isSpanish ? 'Email inválido' : 'Invalid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Password field
                        CustomInput(
                          labelText: isSpanish ? 'Contraseña' : 'Password',
                          hintText: isSpanish ? 'Mínimo 6 caracteres' : 'Minimum 6 characters',
                          prefixIcon: Icons.lock,
                          obscureText: true,
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return isSpanish ? 'Por favor ingresa una contraseña' : 'Please enter a password';
                            }
                            if (value.length < 6) {
                              return isSpanish ? 'Mínimo 6 caracteres' : 'Minimum 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // Forgot password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isSpanish
                                        ? 'Función próximamente disponible'
                                        : 'Feature coming soon',
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              isSpanish ? '¿Olvidaste tu contraseña?' : 'Forgot password?',
                              style: TextStyle(
                                color: Colors.purple[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Login button
                        CustomButton(
                          text: isSpanish ? 'Iniciar Sesión' : 'Sign In',
                          onPressed: _handleEmailLogin,
                          isLoading: _isLoading,
                          backgroundColor: Colors.purple,
                        ),

                        const SizedBox(height: 24),

                        // Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey[300])),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                isSpanish ? 'o continúa con' : 'or continue with',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.grey[300])),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Google sign in
                        GoogleSignInButton(
                          text: isSpanish ? 'Continuar con Google' : 'Continue with Google',
                          onPressed: _handleGoogleSignIn,
                          isLoading: _isGoogleLoading,
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.3, delay: 700.ms),

                const SizedBox(height: 32),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isSpanish ? '¿No tienes cuenta? ' : 'Don\'t have an account? ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<AppState>(context, listen: false).navigateTo(AppScreen.register);
                      },
                      child: Text(
                        isSpanish ? 'Regístrate' : 'Sign Up',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 900.ms),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}