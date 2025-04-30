import 'package:flutter/material.dart';
import 'screens/tela_com_notas.dart';
import 'screens/tela_login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notas com Modal',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/notas': (context) => const TelaComNotas(),
        '/login': (context) => const TelaLogin(),
      },
    );
  }
}