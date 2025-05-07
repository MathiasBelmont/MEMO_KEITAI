import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:memoapi/api.dart';

class TelaComNotas extends StatefulWidget {
  final int? userId;

  const TelaComNotas({Key? key, this.userId}) : super(key: key);

  @override
  _TelaComNotasState createState() => _TelaComNotasState();
}

class _TelaComNotasState extends State<TelaComNotas> {
  List<Map<String, dynamic>> notas = [];
  List<Map<String, dynamic>> notasFiltradas = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _errorMessage;
  bool _isPerformingAction = false;

  final NoteControllerApi _noteApi = NoteControllerApi();

  static final Color _fixedNoteColor = Colors.yellow[200]!;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filtrarNotas);
    if (widget.userId != null) {
      _carregarNotas(widget.userId!);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final Object? args = ModalRoute.of(context)?.settings.arguments;
        final int? routeUserId = args is int ? args : null;
        if (routeUserId != null) {
          _carregarNotas(routeUserId);
        } else if (widget.userId == null) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                "ID do usuário não fornecido. Não é possível carregar as notas.";
          });
        }
      });
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  Future<void> _carregarNotas(int userId, {bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final http.Response httpResponse = await _noteApi
          .getAllByAuthorIdWithHttpInfo(userId);

      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        if (httpResponse.body.isNotEmpty) {
          final List<dynamic> responseData = jsonDecode(httpResponse.body);
          if (mounted) {
            List<Map<String, dynamic>> tempNotas =
                responseData
                    .map((notaData) {
                      if (notaData is Map<String, dynamic>) {
                        return {
                          "id": notaData['id'],
                          "titulo": notaData['title'] ?? 'Sem Título',
                          "conteudo": notaData['content'] ?? '',
                          "cor": _fixedNoteColor,
                        };
                      }
                      return null;
                    })
                    .whereType<Map<String, dynamic>>()
                    .toList();

            tempNotas.sort((a, b) {
              final int? idA = a['id'] as int?;
              final int? idB = b['id'] as int?;
              if (idA != null && idB != null) {
                return idA.compareTo(idB);
              } else if (idA != null) {
                return -1;
              } else if (idB != null) {
                return 1;
              }
              return 0;
            });

            setState(() {
              notas = tempNotas;
              _filtrarNotas();
            });
          }
        } else {
          if (mounted) {
            setState(() {
              notas = [];
              _filtrarNotas();
            });
          }
        }
      } else {
        String apiErrorMsg = "Erro ao carregar notas.";
        if (httpResponse.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(httpResponse.body);
            if (errorData is Map) {
              apiErrorMsg =
                  errorData['message'] ??
                  errorData['error'] ??
                  httpResponse.body;
            } else {
              apiErrorMsg = httpResponse.body;
            }
          } catch (e) {
            apiErrorMsg = httpResponse.body;
          }
        } else {
          apiErrorMsg =
              'Erro ${httpResponse.statusCode} sem mensagem adicional.';
        }
        if (mounted) {
          setState(() {
            _errorMessage = "Erro ${httpResponse.statusCode}: $apiErrorMsg";
          });
        }
      }
    } on ApiException catch (e) {
      print(
        "Erro (ApiException) ao carregar notas: ${e.message} (Code: ${e.code})",
      );
      if (mounted) {
        setState(() {
          _errorMessage =
              "Erro na API ao buscar suas notas: ${e.message ?? 'Erro desconhecido'}. Tente novamente.";
        });
      }
    } catch (e, s) {
      print("Erro geral ao carregar notas: $e\nStackTrace: $s");
      if (mounted) {
        setState(() {
          _errorMessage =
              "Ocorreu um erro ao buscar suas notas. Verifique sua conexão e tente novamente.";
        });
      }
    } finally {
      if (mounted && showLoading) {
        setState(() {
          _isLoading = false;
        });
      } else if (mounted && !showLoading) {
        if (_isLoading) setState(() => _isLoading = false);
      }
    }
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
        notasFiltradas = List.from(notas);
      } else {
        notasFiltradas =
            notas.where((nota) {
              final titulo = nota["titulo"].toString().toLowerCase();
              final conteudo = nota["conteudo"].toString().toLowerCase();
              return titulo.contains(query) || conteudo.contains(query);
            }).toList();
      }
    });
  }

  Future<void> _removerNotaApi(int noteId) async {
    final currentUserId =
        widget.userId ?? ModalRoute.of(context)?.settings.arguments as int?;
    if (currentUserId == null) {
      _showSnackbar("ID do usuário não disponível.", isError: true);
      setState(() => _isPerformingAction = false);
      return;
    }

    setState(() => _isPerformingAction = true);
    try {
      final http.Response httpResponse = await _noteApi.deleteById1WithHttpInfo(
        noteId,
      );
      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        _showSnackbar("Nota removida com sucesso!");
        if (mounted) {
          await _carregarNotas(
            currentUserId,
            showLoading: false,
          ); // Reloads and re-sorts
        }
      } else {
        String errorDetail =
            httpResponse.body.isNotEmpty
                ? httpResponse.body
                : "Sem detalhes adicionais.";
        _showSnackbar(
          "Erro ao remover nota: ${httpResponse.statusCode}. $errorDetail",
          isError: true,
        );
      }
    } on ApiException catch (e) {
      print("Erro (ApiException) ao remover nota: $e");
      _showSnackbar(
        "Erro na API ao remover a nota: ${e.message ?? 'Erro desconhecido'}",
        isError: true,
      );
    } catch (e) {
      print("Erro geral ao remover nota API: $e");
      _showSnackbar("Ocorreu um erro ao remover a nota.", isError: true);
    } finally {
      if (mounted) setState(() => _isPerformingAction = false);
    }
  }

  void confirmarRemoverNota(int indexNoFiltrado) {
    final notaParaRemover = notasFiltradas[indexNoFiltrado];
    final int? noteId = notaParaRemover['id'] as int?;

    if (noteId == null) {
      _showSnackbar("ID da nota inválido.", isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Exclusão"),
          content: Text(
            "Tem certeza que deseja excluir a nota \"${notaParaRemover['titulo']}\"?",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Excluir", style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _removerNotaApi(noteId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _criarNotaApi(String titulo, String conteudo) async {
    final currentUserId =
        widget.userId ?? ModalRoute.of(context)?.settings.arguments as int?;
    if (currentUserId == null) {
      _showSnackbar(
        "ID do usuário não disponível para criar nota.",
        isError: true,
      );
      setState(() => _isPerformingAction = false);
      return;
    }
    setState(() => _isPerformingAction = true);

    final noteCreateDTO = NoteCreateDTO(
      title: titulo,
      content: conteudo,
      authorId: currentUserId,
      color: 'yellow',
    );

    try {
      final http.Response httpResponse = await _noteApi.create1WithHttpInfo(
        noteCreateDTO,
      );
      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        _showSnackbar("Nota criada com sucesso!");
        if (mounted) {
          Navigator.pop(context);
          await _carregarNotas(currentUserId, showLoading: false);
        }
      } else {
        String errorDetail =
            httpResponse.body.isNotEmpty
                ? httpResponse.body
                : "Sem detalhes adicionais.";
        _showSnackbar(
          "Erro ao criar nota: ${httpResponse.statusCode}. $errorDetail",
          isError: true,
        );
      }
    } on ApiException catch (e) {
      print("Erro (ApiException) ao criar nota: $e");
      _showSnackbar(
        "Erro na API ao criar a nota: ${e.message ?? 'Erro desconhecido'}",
        isError: true,
      );
    } catch (e) {
      print("Erro geral ao criar nota API: $e");
      _showSnackbar("Ocorreu um erro ao criar a nota.", isError: true);
    } finally {
      if (mounted) setState(() => _isPerformingAction = false);
    }
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
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: AbsorbPointer(
                absorbing: _isPerformingAction,
                child: Wrap(
                  children: [
                    const Text(
                      'Nova Nota',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Título'),
                      onChanged: (value) => titulo = value,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(labelText: 'Texto'),
                      maxLines: 5,
                      onChanged: (value) => conteudo = value,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 20),
                    _isPerformingAction
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                          onPressed: () {
                            final currentUserId =
                                widget.userId ??
                                ModalRoute.of(context)?.settings.arguments
                                    as int?;
                            if (currentUserId == null) {
                              _showSnackbar(
                                "ID do usuário não encontrado para criar a nota.",
                                isError: true,
                              );
                              return;
                            }
                            if ((titulo.trim().isNotEmpty ||
                                conteudo.trim().isNotEmpty)) {
                              _criarNotaApi(titulo.trim(), conteudo.trim());
                            } else {
                              _showSnackbar(
                                "Título ou conteúdo não podem estar vazios.",
                                isError: true,
                              );
                            }
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Salvar Nota'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _editarNotaApi(
    int noteId,
    String titulo,
    String conteudo,
  ) async {
    final currentUserId =
        widget.userId ?? ModalRoute.of(context)?.settings.arguments as int?;
    if (currentUserId == null) {
      _showSnackbar("ID do usuário não disponível.", isError: true);
      setState(() => _isPerformingAction = false);
      return;
    }

    setState(() => _isPerformingAction = true);

    final noteUpdateDTO = NoteUpdateDTO(title: titulo, content: conteudo);

    try {
      final http.Response httpResponse = await _noteApi.updateById1WithHttpInfo(
        noteId,
        noteUpdateDTO,
      );
      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        _showSnackbar("Nota atualizada com sucesso!");
        if (mounted) {
          Navigator.pop(context);
          await _carregarNotas(currentUserId, showLoading: false);
        }
      } else {
        String errorDetail =
            httpResponse.body.isNotEmpty
                ? httpResponse.body
                : "Sem detalhes adicionais.";
        _showSnackbar(
          "Erro ao atualizar nota: ${httpResponse.statusCode}. $errorDetail",
          isError: true,
        );
      }
    } on ApiException catch (e) {
      print("Erro (ApiException) ao editar nota: $e");
      _showSnackbar(
        "Erro na API ao atualizar a nota: ${e.message ?? 'Erro desconhecido'}",
        isError: true,
      );
    } catch (e) {
      print("Erro geral ao editar nota API: $e");
      _showSnackbar("Ocorreu um erro ao atualizar a nota.", isError: true);
    } finally {
      if (mounted) setState(() => _isPerformingAction = false);
    }
  }

  void abrirModalEditarNota(int indexNoFiltrado) {
    final notaOriginal = notasFiltradas[indexNoFiltrado];
    final int? noteId = notaOriginal["id"] as int?;

    if (noteId == null) {
      _showSnackbar("ID da nota inválido para edição.", isError: true);
      return;
    }

    String titulo = notaOriginal["titulo"]?.toString() ?? '';
    String conteudo = notaOriginal["conteudo"]?.toString() ?? '';

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: AbsorbPointer(
                absorbing: _isPerformingAction,
                child: Wrap(
                  children: [
                    const Text(
                      'Editar Nota',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: titulo,
                      decoration: const InputDecoration(labelText: 'Título'),
                      onChanged: (value) => titulo = value,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: conteudo,
                      decoration: const InputDecoration(labelText: 'Texto'),
                      maxLines: 5,
                      onChanged: (value) => conteudo = value,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 20),
                    _isPerformingAction
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                          onPressed: () {
                            final currentUserId =
                                widget.userId ??
                                ModalRoute.of(context)?.settings.arguments
                                    as int?;
                            if (currentUserId == null) {
                              _showSnackbar(
                                "ID do usuário não encontrado para editar a nota.",
                                isError: true,
                              );
                              return;
                            }
                            if (titulo.trim().isNotEmpty ||
                                conteudo.trim().isNotEmpty) {
                              _editarNotaApi(
                                noteId,
                                titulo.trim(),
                                conteudo.trim(),
                              );
                            } else {
                              _showSnackbar(
                                "Título ou conteúdo não podem estar vazios.",
                                isError: true,
                              );
                            }
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Salvar Alterações'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserIdFromArg =
        ModalRoute.of(context)?.settings.arguments as int?;
    final currentUserId = widget.userId ?? currentUserIdFromArg;

    if (currentUserId == null &&
        !_isLoading &&
        _errorMessage == null &&
        notas.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                "ID do usuário não encontrado. Não é possível carregar as notas.";
          });
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 90, bottom: 80),
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (currentUserId != null)
                                ElevatedButton(
                                  onPressed:
                                      () => _carregarNotas(currentUserId),
                                  child: const Text("Tentar Novamente"),
                                ),
                            ],
                          ),
                        ),
                      )
                      : notasFiltradas.isEmpty
                      ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? "Você ainda não tem notas.\nToque em '+' para adicionar uma!"
                              : "Nenhuma nota encontrada para sua busca.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: () async {
                          if (currentUserId != null) {
                            await _carregarNotas(
                              currentUserId,
                              showLoading: false,
                            );
                          }
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 0.8,
                                  ),
                              itemCount: notasFiltradas.length,
                              itemBuilder: (context, index) {
                                final nota = notasFiltradas[index];
                                return Container(
                                  key: ValueKey(nota['id']),
                                  decoration: BoxDecoration(
                                    color:
                                        nota["cor"] as Color? ??
                                        _fixedNoteColor,
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
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 24),
                                            GestureDetector(
                                              onTap:
                                                  () => abrirModalEditarNota(
                                                    index,
                                                  ),
                                              child: Text(
                                                nota["titulo"]?.toString() ??
                                                    'Sem Título',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap:
                                                    () => abrirModalEditarNota(
                                                      index,
                                                    ),
                                                child: Container(
                                                  color: Colors.transparent,
                                                  width: double.infinity,
                                                  child: Text(
                                                    nota["conteudo"]
                                                            ?.toString() ??
                                                        '',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 20,
                                          ),
                                          color: Colors.redAccent.withOpacity(
                                            0.8,
                                          ),
                                          onPressed:
                                              () => confirmarRemoverNota(index),
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
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16,
                bottom: 10,
              ),
              color: Colors.white.withOpacity(0.95),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Pesquisar notas...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 20,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/login',
                        (Route<dynamic> route) => false,
                      );
                    },
                    tooltip: 'Sair',
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              backgroundColor: Colors.amber,
              onPressed: _isPerformingAction ? null : abrirModalCriarNota,
              tooltip: 'Adicionar Nota',
              child:
                  _isPerformingAction
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                      : const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}
