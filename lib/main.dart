import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notas em Grade',
      debugShowCheckedModeBanner: false,
      home: TelaComNotas(),
    );
  }
}

class TelaComNotas extends StatelessWidget {
  final List<Map<String, String>> notas = List.generate(
    30,
    (index) => {
      "titulo": "Nota ${index + 1}",
      "conteudo": "Conteúdo da nota número ${index + 1}.",
    },
  );

  final List<Color> coresPastel = [
    Color(0xFFFFF1C1),
    Color(0xFFD0F4DE),
    Color(0xFFFFD6E0),
    Color(0xFFCDE7FF),
    Color(0xFFE4C1F9),
    Color(0xFFFFF5BA),
  ];

  Color corAleatoria() {
    final random = Random();
    return coresPastel[random.nextInt(coresPastel.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Corpo com grid
          Positioned.fill(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(top: 80, bottom: 80),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: notas.map((nota) {
                      return Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: corAleatoria(),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nota["titulo"]!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                nota["conteudo"]!,
                                style: TextStyle(fontSize: 12),
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),

          // AppBar com botão usuário
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              padding: EdgeInsets.only(top: 30, left: 16),
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.person, color: Colors.white),
                    onPressed: () {
                      // Ação do botão
                    },
                  ),
                ),
              ),
            ),
          ),

          // Botão flutuante inferior
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  // Ação do botão
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
