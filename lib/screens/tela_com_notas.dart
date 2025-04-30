import 'package:flutter/material.dart';
import 'dart:math';

class TelaComNotas extends StatefulWidget {
  const TelaComNotas({super.key});

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
    notasFiltradas = notas;
    _searchController.addListener(_filtrarNotas);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrarNotas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        notasFiltradas = notas;
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
      _filtrarNotas();
    });
  }

  void abrirModalCriarNota() {
    String titulo = '';
    String conteudo = '';
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
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
              const Text(
                'Nova Nota',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Título'),
                onChanged: (value) => titulo = value,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Texto'),
                maxLines: 5,
                onChanged: (value) => conteudo = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (titulo.trim().isNotEmpty || conteudo.trim().isNotEmpty) {
                    setState(() {
                      notas.add({
                        "titulo": titulo.trim(),
                        "conteudo": conteudo.trim(),
                        "cor": corAleatoria(),
                      });
                      _filtrarNotas();
                    });
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Salvar Nota'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 24),
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
      shape: const RoundedRectangleBorder(
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
              const Text(
                'Editar Nota',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Título'),
                controller: TextEditingController(text: titulo),
                onChanged: (value) => titulo = value,
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(labelText: 'Texto'),
                maxLines: 5,
                controller: TextEditingController(text: conteudo),
                onChanged: (value) => conteudo = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (titulo.trim().isNotEmpty || conteudo.trim().isNotEmpty) {
                    setState(() {
                      notas[index] = {
                        "titulo": titulo.trim(),
                        "conteudo": conteudo.trim(),
                        "cor": cor,
                      };
                      _filtrarNotas();
                    });
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Salvar Alterações'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 24),
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
              padding: const EdgeInsets.only(top: 80, bottom: 80),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: notasFiltradas.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          boxShadow: const [
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
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 24),
                                  GestureDetector(
                                    onTap: () =>
                                        abrirModalEditarNota(notas.indexOf(nota)),
                                    child: Text(
                                      nota["titulo"]!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: Text(
                                      nota["conteudo"]!,
                                      style: const TextStyle(fontSize: 12),
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
                                icon: const Icon(Icons.delete, size: 20),
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
              padding: const EdgeInsets.only(top: 30, left: 16, right: 16),
              color: Colors.transparent,
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
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
                      icon: const Icon(Icons.exit_to_app, color: Colors.white),
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Pesquisar notas...',
                        filled: true,
                        fillColor: Colors.grey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
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
              decoration: const BoxDecoration(
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
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: abrirModalCriarNota,
              ),
            ),
          ),
        ],
      ),
    );
  }
}