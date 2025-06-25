// main.dart
import 'package:flutter/material.dart';
import 'screens/tela_com_notas.dart';
import 'screens/tela_login.dart';
import 'screens/tela_cadastro.dart'; // Importe a nova tela

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'memo.io',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // ou '/cadastro' se quiser testar direto
      routes: {
        '/login': (context) => const TelaLogin(),
        '/cadastro': (context) => const TelaCadastro(), // Adicione esta linha
        '/notas': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final int? userId = args is int ? args : null;
          return TelaComNotas(userId: userId);
        },
      },
    );
  }
}