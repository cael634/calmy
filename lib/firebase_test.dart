import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Asegúrate de que este archivo esté generado
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase se inicializó correctamente');
    runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Firebase conectado!')))));
  } catch (e) {
    print('❌ Error al inicializar Firebase: $e');
    runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Error en Firebase!')))));
  }
}