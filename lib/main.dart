import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notas com Modal',
      debugShowCheckedModeBanner: false,
      home: TelaComNotas(),
    );
  }
}

class TelaComNotas extends StatefulWidget {
  @override
  _TelaComNotasState createState() => _TelaComNotasState();
}

class _TelaComNotasState extends State<TelaComNotas> {
  List<Map<String, String>> notas = [];

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

  void removerNota(int index) {
    setState(() {
      notas.removeAt(index);
    });
  }

  void abrirModalCriarNota() {
    String titulo = '';
    String conteudo = '';
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Wrap(
            children: [
              Text(
                'Nova Nota',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Título'),
                onChanged: (value) => titulo = value,
              ),
              SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(labelText: 'Texto'),
                maxLines: 5,
                onChanged: (value) => conteudo = value,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (titulo.trim().isNotEmpty || conteudo.trim().isNotEmpty) {
                    setState(() {
                      notas.add({
                        "titulo": titulo.trim(),
                        "conteudo": conteudo.trim(),
                      });
                    });
                    Navigator.pop(context); // Fecha modal
                  }
                },
                icon: Icon(Icons.save),
                label: Text('Salvar Nota'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
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
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: notas.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1, // largura == altura
                    ),
                    itemBuilder: (context, index) {
                      final nota = notas[index];
                      return SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          children: [
                            Container(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 24),
                                      Text(
                                        nota["titulo"]!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        nota["conteudo"]!,
                                        style: TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 5,
                                      ),
                                    ],
                                  ),
                                  Spacer(), // força altura restante a ser ocupada
                                ],
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: Icon(Icons.delete, size: 20),
                                color: Colors.redAccent,
                                onPressed: () => removerNota(index),
                                tooltip: 'Excluir nota',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
                    onPressed: () {},
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
                onPressed: abrirModalCriarNota,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
