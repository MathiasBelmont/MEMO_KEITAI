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
      title: 'memo.io',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const TelaLogin(),
        '/notas': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final int? userId = args is int ? args : null;
          return TelaComNotas(userId: userId);
        },
      },
    );
  }
}
