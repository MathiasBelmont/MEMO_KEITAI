import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:memoapi/api.dart';
import 'package:markdown_widget/markdown_widget.dart';

class TelaComNotas extends StatefulWidget {
  final int? userId;

  const TelaComNotas({super.key, this.userId});

  @override
  State<TelaComNotas> createState() => _TelaComNotasState();
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

  int? _longPressedNoteId;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filtrarNotas);
    if (widget.userId != null) {
      _carregarNotas(widget.userId!);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final Object? args = ModalRoute.of(context)?.settings.arguments;
        final int? routeUserId = args is int ? args : null;
        if (routeUserId != null) {
          _carregarNotas(routeUserId);
        } else {
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
      final http.Response httpResponse =
      await _noteApi.getAllByAuthorIdWithHttpInfo(userId);

      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        if (httpResponse.body.isNotEmpty) {
          final List<dynamic> responseData = jsonDecode(httpResponse.body);
          if (mounted) {
            List<Map<String, dynamic>> tempNotas = responseData
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
        if (httpResponse.statusCode == 404) {
          if (mounted) {
            setState(() {
              notas = [];
              _filtrarNotas();
              _errorMessage = null;
            });
          }
        } else {
          String apiErrorMsg = "Erro ao carregar notas.";
          if (httpResponse.body.isNotEmpty) {
            try {
              final errorData = jsonDecode(httpResponse.body);
              if (errorData is Map) {
                apiErrorMsg = errorData['message'] ??
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
              notas = [];
              _filtrarNotas();
            });
          }
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        if (e.code == 404) {
          setState(() {
            notas = [];
            _filtrarNotas();
            _errorMessage = null;
          });
        } else {
          setState(() {
            _errorMessage =
            "Erro na API ao buscar suas notas: ${e.message ?? 'Erro desconhecido (${e.code})'}. Tente novamente.";
            notas = [];
            _filtrarNotas();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
          "Ocorreu um erro ao buscar suas notas. Verifique sua conexão e tente novamente.";
          notas = [];
          _filtrarNotas();
        });
      }
    } finally {
      if (mounted) {
        if (showLoading || _isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtrarNotas);
    _searchController.dispose();
    super.dispose();
  }

  void _filtrarNotas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        notasFiltradas = List.from(notas);
      } else {
        notasFiltradas = notas.where((nota) {
          final titulo = nota["titulo"].toString().toLowerCase();
          final conteudo = nota["conteudo"].toString().toLowerCase();
          return titulo.contains(query) || conteudo.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _removerNotaApi(int noteId) async {
    if (!mounted) return;
    final currentUserId =
        widget.userId ?? ModalRoute.of(context)?.settings.arguments as int?;
    if (currentUserId == null) {
      _showSnackbar("ID do usuário não disponível.", isError: true);
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
          setState(() {
            _longPressedNoteId = null;
          });
          await _carregarNotas(
            currentUserId,
            showLoading: false,
          );
        }
      } else {
        String errorDetail = httpResponse.body.isNotEmpty
            ? httpResponse.body
            : "Sem detalhes adicionais.";
        _showSnackbar(
          "Erro ao remover nota: ${httpResponse.statusCode}. $errorDetail",
          isError: true,
        );
      }
    } on ApiException catch (e) {
      _showSnackbar(
        "Erro na API ao remover a nota: ${e.message ?? 'Erro desconhecido'}",
        isError: true,
      );
    } catch (e) {
      _showSnackbar("Ocorreu um erro ao remover a nota.", isError: true);
    } finally {
      if (mounted) setState(() => _isPerformingAction = false);
    }
  }

  void confirmarRemoverNota(int indexNoFiltrado) {
    if (!mounted) return;
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
    if (!mounted) return;
    final currentUserId =
        widget.userId ?? ModalRoute.of(context)?.settings.arguments as int?;
    if (currentUserId == null) {
      _showSnackbar(
        "ID do usuário não disponível para criar nota.",
        isError: true,
      );
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
        String errorDetail = httpResponse.body.isNotEmpty
            ? httpResponse.body
            : "Sem detalhes adicionais.";
        _showSnackbar(
          "Erro ao criar nota: ${httpResponse.statusCode}. $errorDetail",
          isError: true,
        );
      }
    } on ApiException catch (e) {
      _showSnackbar(
        "Erro na API ao criar a nota: ${e.message ?? 'Erro desconhecido'}",
        isError: true,
      );
    } catch (e) {
      _showSnackbar("Ocorreu um erro ao criar a nota.", isError: true);
    } finally {
      if (mounted) setState(() => _isPerformingAction = false);
    }
  }

  void abrirModalCriarNota() {
    setState(() {
      _longPressedNoteId = null;
    });

    _abrirModalEdicao(
      tituloModal: 'Nova Nota',
      onSave: (titulo, conteudo) {
        _criarNotaApi(titulo, conteudo);
      },
    );
  }

  Future<void> _editarNotaApi(
      int noteId,
      String titulo,
      String conteudo,
      ) async {
    if (!mounted) return;
    final currentUserId =
        widget.userId ?? ModalRoute.of(context)?.settings.arguments as int?;
    if (currentUserId == null) {
      _showSnackbar("ID do usuário não disponível.", isError: true);
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
        String errorDetail = httpResponse.body.isNotEmpty
            ? httpResponse.body
            : "Sem detalhes adicionais.";
        _showSnackbar(
          "Erro ao atualizar nota: ${httpResponse.statusCode}. $errorDetail",
          isError: true,
        );
      }
    } on ApiException catch (e) {
      _showSnackbar(
        "Erro na API ao atualizar a nota: ${e.message ?? 'Erro desconhecido'}",
        isError: true,
      );
    } catch (e) {
      _showSnackbar("Ocorreu um erro ao atualizar a nota.", isError: true);
    } finally {
      if (mounted) setState(() => _isPerformingAction = false);
    }
  }

  void abrirModalEditarNota(int indexNoFiltrado) {
    setState(() {
      _longPressedNoteId = null;
    });

    final notaOriginal = notasFiltradas[indexNoFiltrado];
    final int? noteId = notaOriginal["id"] as int?;

    if (noteId == null) {
      _showSnackbar("ID da nota inválido para edição.", isError: true);
      return;
    }

    _abrirModalEdicao(
      tituloModal: 'Editar Nota',
      tituloInicial: notaOriginal["titulo"]?.toString() ?? '',
      conteudoInicial: notaOriginal["conteudo"]?.toString() ?? '',
      onSave: (titulo, conteudo) {
        _editarNotaApi(noteId, titulo, conteudo);
      },
    );
  }

  void _abrirModalEdicao({
    required String tituloModal,
    String tituloInicial = '',
    String conteudoInicial = '',
    required Function(String, String) onSave,
  }) {
    final tituloController = TextEditingController(text: tituloInicial);
    final conteudoController = TextEditingController(text: conteudoInicial);

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
                    Text(
                      tituloModal,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tituloController,
                      decoration: const InputDecoration(labelText: 'Título'),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: conteudoController,
                      decoration: const InputDecoration(labelText: 'Texto (Markdown)'),
                      maxLines: 8,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 20),
                    _isPerformingAction
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                      onPressed: () {
                        final titulo = tituloController.text.trim();
                        final conteudo = conteudoController.text.trim();
                        if (titulo.isNotEmpty || conteudo.isNotEmpty) {
                          onSave(titulo, conteudo);
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
    ).whenComplete(() {
      tituloController.dispose();
      conteudoController.dispose();
      if (mounted && _isPerformingAction) {
        setState(() {
          _isPerformingAction = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserIdFromArg =
    ModalRoute.of(context)?.settings.arguments as int?;
    final currentUserId = widget.userId ?? currentUserIdFromArg;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (_longPressedNoteId != null) {
            setState(() {
              _longPressedNoteId = null;
            });
          }
          FocusScope.of(context).unfocus(); // Recolhe o teclado
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.only(top: 90, bottom: 80),
                child: _isLoading
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
                        if (currentUserId != null &&
                            _errorMessage !=
                                "ID do usuário não fornecido. Não é possível carregar as notas.")
                          ElevatedButton(
                            onPressed: () =>
                                _carregarNotas(currentUserId),
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
                      setState(() {
                        _longPressedNoteId = null;
                      });
                      await _carregarNotas(
                        currentUserId,
                        showLoading: false,
                      );
                    }
                  },
                  child: SingleChildScrollView(
                    physics:
                    const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics:
                        const NeverScrollableScrollPhysics(),
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
                          final notaId = nota['id'] as int?;
                          final isLongPressed =
                              _longPressedNoteId == notaId;

                          return GestureDetector(
                            onLongPress: () {
                              setState(() {
                                _longPressedNoteId = notaId;
                              });
                            },
                            onTap: () {
                              if (isLongPressed) {
                                setState(() {
                                  _longPressedNoteId = null;
                                });
                              } else {
                                abrirModalEditarNota(index);
                              }
                            },
                            child: Container(
                              key: ValueKey(nota['id']),
                              decoration: BoxDecoration(
                                color: nota["cor"] as Color? ??
                                    _fixedNoteColor,
                                borderRadius:
                                BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: isLongPressed
                                        ? Colors.blue.withAlpha((0.5 * 255).round())
                                        : Colors.black12,
                                    blurRadius: isLongPressed ? 6 : 4,
                                    spreadRadius: isLongPressed ? 1 : 0,
                                    offset: const Offset(2, 2),
                                  ),
                                ],
                                border: isLongPressed
                                    ? Border.all(
                                    color: Colors.blueAccent,
                                    width: 2)
                                    : null,
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: [
                                        Text(
                                          nota["titulo"]
                                              ?.toString() ??
                                              'Sem Título',
                                          style:
                                          const TextStyle(
                                            fontWeight:
                                            FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow
                                              .ellipsis,
                                          maxLines: 2,
                                        ),
                                        const SizedBox(height: 4),
                                        Expanded(
                                          child: SizedBox(
                                            height: 100, // Limita altura da pré-visualização
                                            width: double.infinity,
                                            child: IgnorePointer( // Impede scroll e interação no card
                                              child: MarkdownWidget(
                                                data: nota["conteudo"]?.toString() ?? '',
                                                shrinkWrap: true,
                                                config: MarkdownConfig(
                                                    configs: [
                                                      PConfig(
                                                        textStyle: const TextStyle(fontSize: 12, color: Colors.black87),
                                                      ),
                                                    ]
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isLongPressed)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 20,
                                        ),
                                        color: Colors.redAccent
                                            .withAlpha((255 * 0.8)
                                            .round()),
                                        onPressed: () =>
                                            confirmarRemoverNota(
                                                index),
                                        tooltip: 'Excluir nota',
                                      ),
                                    ),
                                ],
                              ),
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
                color: Colors.white.withAlpha((255 * 0.95).round()),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onTap: () {
                          if (_longPressedNoteId != null) {
                            setState(() {
                              _longPressedNoteId = null;
                            });
                          }
                        },
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
                        setState(() {
                          _longPressedNoteId = null;
                        });
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
                onPressed:
                _isPerformingAction ? null : abrirModalCriarNota,
                tooltip: 'Adicionar Nota',
                child: _isPerformingAction &&
                    ModalRoute.of(context)?.isCurrent == true
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
      ),
    );
  }
}