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
  List<Map<String, dynamic>> notas = [];
  List<Map<String, dynamic>> notasFiltradas = [];
  final TextEditingController _searchController = TextEditingController();

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
  void initState() {
    super.initState();
    notasFiltradas = notas; // Inicialmente, exibe todas as notas
    _searchController.addListener(_filtrarNotas); // Adiciona listener para busca
  }

  @override
  void dispose() {
    _searchController.dispose(); // Libera o controlador
    super.dispose();
  }

  void _filtrarNotas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        notasFiltradas = notas; // Mostra todas as notas se a busca estiver vazia
      } else {
        notasFiltradas = notas.where((nota) {
          final titulo = nota["titulo"].toLowerCase();
          final conteudo = nota["conteudo"].toLowerCase();
          return titulo.contains(query) || conteudo.contains(query);
        }).toList();
      }
    });
  }

  void removerNota(int index) {
    setState(() {
      notas.removeAt(index);
      _filtrarNotas(); // Atualiza a lista filtrada após remoção
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
                        "cor": corAleatoria(),
                      });
                      _filtrarNotas(); // Atualiza a lista filtrada após adição
                    });
                    Navigator.pop(context);
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

  void abrirModalEditarNota(int index) {
    String titulo = notas[index]["titulo"]!;
    String conteudo = notas[index]["conteudo"]!;
    Color cor = notas[index]["cor"];
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
                'Editar Nota',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: 'Título'),
                controller: TextEditingController(text: titulo),
                onChanged: (value) => titulo = value,
              ),
              SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(labelText: 'Texto'),
                maxLines: 5,
                controller: TextEditingController(text: conteudo),
                onChanged: (value) => conteudo = value,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (titulo.trim().isNotEmpty || conteudo.trim().isNotEmpty) {
                    setState(() {
                      notas[index] = {
                        "titulo": titulo.trim(),
                        "conteudo": conteudo.trim(),
                        "cor": cor,
                      };
                      _filtrarNotas(); // Atualiza a lista filtrada após edição
                    });
                    Navigator.pop(context);
                  }
                },
                icon: Icon(Icons.save),
                label: Text('Salvar Alterações'),
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
                    itemCount: notasFiltradas.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final nota = notasFiltradas[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: nota["cor"],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 24),
                                  GestureDetector(
                                    onTap: () => abrirModalEditarNota(
                                        notas.indexOf(nota)),
                                    child: Text(
                                      nota["titulo"]!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Expanded(
                                    child: Text(
                                      nota["conteudo"]!,
                                      style: TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: Icon(Icons.delete, size: 20),
                                color: Colors.redAccent,
                                onPressed: () => removerNota(notas.indexOf(nota)),
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              padding: EdgeInsets.only(top: 30, left: 16, right: 16),
              color: Colors.transparent,
              child: Row(
                children: [
                  Container(
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
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Pesquisar notas...',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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