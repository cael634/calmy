import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:calmy/providers/app_state.dart' ;
import '../providers/language_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';
import '../models/app_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!_acceptTerms) {
      final isSpanish = Provider.of<LanguageProvider>(context, listen: false).isSpanish;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isSpanish 
                ? 'Debes aceptar los términos y condiciones'
                : 'You must accept the terms and conditions',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulate registration delay
      await Future.delayed(const Duration(seconds: 2));
      
      final appState = Provider.of<AppState>(context, listen: false);
      appState.login(_emailController.text);
      appState.navigateTo(AppScreen.home);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isGoogleLoading = true);

    try {
      // Simulate Google sign-up delay
      await Future.delayed(const Duration(seconds: 2));
      
      final appState = Provider.of<AppState>(context, listen: false);
      appState.login('google_user@gmail.com');
      appState.navigateTo(AppScreen.home);
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isSpanish = languageProvider.isSpanish;

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
                        child: Text('🌱', style: TextStyle(fontSize: 50)),
                      ),
                    ).animate().scale(duration: 600.ms).then().shimmer(),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      isSpanish ? 'Únete a Calmi' : 'Join Calmie',
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
                          ? 'Comienza tu viaje hacia el bienestar'
                          : 'Start your journey to wellness',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Benefits section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isSpanish ? '¿Por qué elegir Calmi?' : 'Why choose Calmie?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBenefitItem(
                        icon: '🧘‍♀️',
                        text: isSpanish 
                            ? 'Ejercicios de respiración personalizados'
                            : 'Personalized breathing exercises',
                      ),
                      _buildBenefitItem(
                        icon: '🐱',
                        text: isSpanish 
                            ? 'Mascota virtual que crece contigo'
                            : 'Virtual pet that grows with you',
                      ),
                      _buildBenefitItem(
                        icon: '🏆',
                        text: isSpanish 
                            ? 'Sistema de logros motivacional'
                            : 'Motivational achievement system',
                      ),
                      _buildBenefitItem(
                        icon: '📱',
                        text: isSpanish 
                            ? 'Acceso gratuito a todas las funciones'
                            : 'Free access to all features',
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 0.3, delay: 500.ms),
                
                const SizedBox(height: 32),
                
                // Registration form
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
                          isSpanish ? 'Crear Cuenta' : 'Create Account',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          isSpanish 
                              ? 'Completa la información para comenzar'
                              : 'Fill in the information to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Name field
                        CustomInput(
                          labelText: isSpanish ? 'Nombre completo' : 'Full name',
                          hintText: isSpanish ? 'Tu nombre' : 'Your name',
                          prefixIcon: Icons.person,
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return isSpanish ? 'Por favor ingresa tu nombre' : 'Please enter your name';
                            }
                            if (value.length < 2) {
                              return isSpanish ? 'Mínimo 2 caracteres' : 'Minimum 2 characters';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
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
                        
                        const SizedBox(height: 20),
                        
                        // Confirm password field
                        CustomInput(
                          labelText: isSpanish ? 'Confirmar contraseña' : 'Confirm password',
                          hintText: isSpanish ? 'Repite tu contraseña' : 'Repeat your password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          controller: _confirmPasswordController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return isSpanish ? 'Por favor confirma tu contraseña' : 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return isSpanish ? 'Las contraseñas no coinciden' : 'Passwords don\'t match';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Terms and conditions
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) {
                                setState(() {
                                  _acceptTerms = value ?? false;
                                });
                              },
                              activeColor: Colors.purple,
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _acceptTerms = !_acceptTerms;
                                  });
                                },
                                child: Text(
                                  isSpanish 
                                      ? 'Acepto los términos y condiciones y la política de privacidad'
                                      : 'I accept the terms and conditions and privacy policy',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Register button
                        CustomButton(
                          text: isSpanish ? 'Crear Cuenta' : 'Create Account',
                          onPressed: _handleRegister,
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
                                isSpanish ? 'o regístrate con' : 'or sign up with',
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
                        
                        // Google sign up
                        GoogleSignInButton(
                          text: isSpanish ? 'Registrarse con Google' : 'Sign up with Google',
                          onPressed: _handleGoogleSignUp,
                          isLoading: _isGoogleLoading,
                        ),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.3, delay: 700.ms),
                
                const SizedBox(height: 32),
                
                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isSpanish ? '¿Ya tienes cuenta? ' : 'Already have an account? ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<AppState>(context, listen: false).navigateTo(AppScreen.login);
                      },
                      child: Text(
                        isSpanish ? 'Iniciar Sesión' : 'Sign In',
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

  Widget _buildBenefitItem({required String icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
