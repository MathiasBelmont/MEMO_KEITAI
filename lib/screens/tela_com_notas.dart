import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:memoapi/api.dart';
import 'package:markdown_widget/markdown_widget.dart';

class _NoteEditorModal extends StatefulWidget {
  final String tituloModal;
  final String tituloInicial;
  final String conteudoInicial;
  final String corInicial;
  final Future<bool> Function(String, String, String) onSave;

  const _NoteEditorModal({
    required this.tituloModal,
    this.tituloInicial = '',
    this.conteudoInicial = '',
    this.corInicial = 'yellow',
    required this.onSave,
  });

  @override
  State<_NoteEditorModal> createState() => _NoteEditorModalState();
}

class _NoteEditorModalState extends State<_NoteEditorModal> {
  late final TextEditingController _tituloController;
  late final TextEditingController _conteudoController;
  late String _selectedColor;
  bool _isSaving = false;

  final Map<String, Color> _availableColors = {
    'yellow': Colors.yellow[200]!,
    'red': Colors.red[200]!,
    'blue': Colors.blue[200]!,
    'green': Colors.green[200]!,
  };

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.tituloInicial);
    _conteudoController = TextEditingController(text: widget.conteudoInicial);
    _selectedColor = widget.corInicial;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12.0,
          children: _availableColors.entries.map((entry) {
            final colorName = entry.key;
            final colorValue = entry.value;
            final isSelected = _selectedColor == colorName;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = colorName;
                });
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorValue,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.black, width: 2.5)
                      : Border.all(color: Colors.grey.shade400, width: 1.0),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.black, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: AbsorbPointer(
        absorbing: _isSaving,
        child: Wrap(
          runSpacing: 16,
          children: [
            Text(widget.tituloModal, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(controller: _tituloController, decoration: const InputDecoration(labelText: 'Título'), textInputAction: TextInputAction.next),
            TextFormField(controller: _conteudoController, decoration: const InputDecoration(labelText: 'Texto (Markdown)'), maxLines: 6, textInputAction: TextInputAction.done),
            _buildColorSelector(),
            const SizedBox(height: 8),
            _isSaving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                onPressed: () async {
                  final titulo = _tituloController.text.trim();
                  final conteudo = _conteudoController.text.trim();
                  if (titulo.isEmpty && conteudo.isEmpty) return;
                  setState(() => _isSaving = true);
                  final bool result = await widget.onSave(titulo, conteudo, _selectedColor);
                  if (mounted) {
                    Navigator.pop(context, result);
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Salvar Nota'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
          ],
        ),
      ),
    );
  }
}

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
  int? _longPressedNoteId;
  bool _isPerformingAction = false;

  final NoteControllerApi _noteApi = NoteControllerApi();

  Color _getColorFromString(String? colorString) {
    switch (colorString?.toLowerCase()) {
      case 'red': return Colors.red[200]!;
      case 'blue': return Colors.blue[200]!;
      case 'green': return Colors.green[200]!;
      case 'yellow':
      default: return Colors.yellow[200]!;
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filtrarNotas);
    _carregarNotasIniciais();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtrarNotas);
    _searchController.dispose();
    super.dispose();
  }

  void _carregarNotasIniciais() {
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
          setState(() { _isLoading = false; _errorMessage = "ID do usuário não fornecido."; });
        }
      });
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? Colors.redAccent : Colors.green));
  }

  Future<void> _carregarNotas(int userId, {bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() { _isLoading = true; _errorMessage = null; });
    }
    try {
      final http.Response httpResponse = await _noteApi.getAllByAuthorIdWithHttpInfo(userId);
      if (!mounted) return;
      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        List<Map<String, dynamic>> tempNotas = [];
        if (httpResponse.body.isNotEmpty) {
          final List<dynamic> responseData = jsonDecode(httpResponse.body);
          tempNotas = responseData.map((notaData) {
            if (notaData is Map<String, dynamic>) {
              final colorString = notaData['color']?.toString() ?? 'yellow';
              return {
                "id": notaData['id'],
                "titulo": notaData['title'] ?? 'Sem Título',
                "conteudo": notaData['content'] ?? '',
                "colorString": colorString,
                "cor": _getColorFromString(colorString),
              };
            }
            return null;
          }).whereType<Map<String, dynamic>>().toList();
          tempNotas.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
        }
        setState(() { notas = tempNotas; _filtrarNotas(); _errorMessage = null; });
      } else {
        setState(() { _errorMessage = "Erro ao carregar notas: ${httpResponse.statusCode}"; notas = []; _filtrarNotas(); });
      }
    } catch (e) {
      if (mounted) { setState(() { _errorMessage = "Ocorreu um erro ao buscar suas notas."; notas = []; _filtrarNotas(); }); }
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  void _filtrarNotas() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      notasFiltradas = query.isEmpty
          ? List.from(notas)
          : notas.where((nota) {
        final titulo = nota["titulo"].toString().toLowerCase();
        final conteudo = nota["conteudo"].toString().toLowerCase();
        return titulo.contains(query) || conteudo.contains(query);
      }).toList();
    });
  }

  Future<void> _removerNotaApi(int noteId) async {
    if (!mounted) return;
    final currentUserId = widget.userId ?? ModalRoute.of(context)?.settings.arguments as int?;
    if (currentUserId == null) {
      _showSnackbar("ID do usuário não disponível.", isError: true);
      return;
    }
    setState(() => _isPerformingAction = true);
    try {
      final http.Response response = await _noteApi.deleteById1WithHttpInfo(noteId);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showSnackbar("Nota removida com sucesso!");
        if (mounted) {
          setState(() => _longPressedNoteId = null);
          await _carregarNotas(currentUserId, showLoading: false);
        }
      } else {
        _showSnackbar("Erro ao remover nota (${response.statusCode})", isError: true);
      }
    } catch (e) {
      _showSnackbar("Ocorreu um erro inesperado ao remover a nota.", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isPerformingAction = false);
      }
    }
  }

  void confirmarRemoverNota(int indexNoFiltrado) {
    if (_isPerformingAction) return;
    final notaParaRemover = notasFiltradas[indexNoFiltrado];
    final int? noteId = notaParaRemover['id'] as int?;
    if (noteId == null) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmar Exclusão"),
          content: Text("Tem certeza que deseja excluir a nota \"${notaParaRemover['titulo']}\"?"),
          actions: <Widget>[
            TextButton(child: const Text("Cancelar"), onPressed: () => Navigator.of(context).pop()),
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

  Future<bool> _criarNotaApi(String titulo, String conteudo, String cor) async {
    final currentUserId = widget.userId ?? ModalRoute.of(context)?.settings.arguments as int?;
    if (currentUserId == null) {
      _showSnackbar("ID do usuário não disponível.", isError: true);
      return false;
    }
    final noteCreateDTO = NoteCreateDTO(title: titulo, content: conteudo, authorId: currentUserId, color: cor);
    try {
      final response = await _noteApi.create1WithHttpInfo(noteCreateDTO);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showSnackbar("Nota criada com sucesso!");
        return true;
      }
      _showSnackbar("Erro ao criar a nota (${response.statusCode})", isError: true);
      return false;
    } catch (e) {
      _showSnackbar("Ocorreu um erro ao criar a nota.", isError: true);
      return false;
    }
  }

  Future<bool> _editarNotaApi(int noteId, String titulo, String conteudo, String cor) async {
    final noteUpdateDTO = NoteUpdateDTO(title: titulo, content: conteudo, color: cor);
    try {
      final response = await _noteApi.updateById1WithHttpInfo(noteId, noteUpdateDTO);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showSnackbar("Nota atualizada com sucesso!");
        return true;
      }
      _showSnackbar("Erro ao atualizar a nota (${response.statusCode})", isError: true);
      return false;
    } catch (e) {
      _showSnackbar("Ocorreu um erro ao atualizar a nota.", isError: true);
      return false;
    }
  }

  Future<void> _abrirModal(Widget modalContent) async {
    final bool? sucesso = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => modalContent,
    );
    if (sucesso == true) {
      final currentUserId = widget.userId ?? ModalRoute.of(context)?.settings.arguments as int?;
      if (currentUserId != null) {
        await _carregarNotas(currentUserId, showLoading: false);
      }
    }
  }

  void abrirModalCriarNota() {
    setState(() => _longPressedNoteId = null);
    _abrirModal(
      _NoteEditorModal(
        tituloModal: 'Nova Nota',
        onSave: (titulo, conteudo, cor) => _criarNotaApi(titulo, conteudo, cor),
      ),
    );
  }

  void abrirModalEditarNota(int indexNoFiltrado) {
    setState(() => _longPressedNoteId = null);
    final notaOriginal = notasFiltradas[indexNoFiltrado];
    final int? noteId = notaOriginal["id"] as int?;
    if (noteId == null) return;
    _abrirModal(
      _NoteEditorModal(
        tituloModal: 'Editar Nota',
        tituloInicial: notaOriginal["titulo"]?.toString() ?? '',
        conteudoInicial: notaOriginal["conteudo"]?.toString() ?? '',
        corInicial: notaOriginal["colorString"]?.toString() ?? 'yellow',
        onSave: (titulo, conteudo, cor) => _editarNotaApi(noteId, titulo, conteudo, cor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = widget.userId ?? ModalRoute.of(context)?.settings.arguments as int?;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (_longPressedNoteId != null) { setState(() => _longPressedNoteId = null); }
          FocusScope.of(context).unfocus();
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
                    ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red, fontSize: 16)), const SizedBox(height: 10), if (currentUserId != null) ElevatedButton(onPressed: () => _carregarNotas(currentUserId), child: const Text("Tentar Novamente"))])))
                    : notasFiltradas.isEmpty
                    ? Center(child: Text(_searchController.text.isEmpty ? "Você ainda não tem notas.\nToque em '+' para adicionar uma!" : "Nenhuma nota encontrada para sua busca.", textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Colors.grey)))
                    : RefreshIndicator(
                  onRefresh: () async {
                    if (_isPerformingAction) return;
                    if (currentUserId != null) {
                      setState(() => _longPressedNoteId = null);
                      await _carregarNotas(currentUserId, showLoading: false);
                    }
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.8),
                    itemCount: notasFiltradas.length,
                    itemBuilder: (context, index) {
                      final nota = notasFiltradas[index];
                      final notaId = nota['id'] as int?;
                      final isLongPressed = _longPressedNoteId == notaId;
                      return GestureDetector(
                        onLongPress: () => setState(() => _longPressedNoteId = notaId),
                        onTap: () {
                          if (isLongPressed) {
                            setState(() => _longPressedNoteId = null);
                          } else {
                            abrirModalEditarNota(index);
                          }
                        },
                        child: Container(
                          key: ValueKey(nota['id']),
                          decoration: BoxDecoration(color: nota["cor"] as Color?, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: isLongPressed ? Colors.blue.withOpacity(0.5) : Colors.black12, blurRadius: isLongPressed ? 6 : 4, spreadRadius: isLongPressed ? 1 : 0)], border: isLongPressed ? Border.all(color: Colors.blueAccent, width: 2) : null),
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(nota["titulo"]?.toString() ?? 'Sem Título', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 2),
                                    const SizedBox(height: 4),
                                    Expanded(child: IgnorePointer(child: MarkdownWidget(data: nota["conteudo"]?.toString() ?? '', shrinkWrap: true, config: MarkdownConfig(configs: [PConfig(textStyle: const TextStyle(fontSize: 12, color: Colors.black87))])))),
                                  ],
                                ),
                              ),
                              if (isLongPressed)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    color: Colors.redAccent.withOpacity(0.8),
                                    onPressed: _isPerformingAction ? null : () => confirmarRemoverNota(index),
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
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 10, 16, 10),
                color: Colors.white.withOpacity(0.95),
                child: Row(
                  children: [
                    Expanded(child: TextField(controller: _searchController, onTap: () => setState(() => _longPressedNoteId = null), decoration: InputDecoration(hintText: 'Pesquisar notas...', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide.none), filled: true, fillColor: Colors.grey[200], contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20)))),
                    IconButton(icon: const Icon(Icons.logout), onPressed: () { setState(() => _longPressedNoteId = null); Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false); }, tooltip: 'Sair'),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton(
                backgroundColor: _isPerformingAction ? Colors.grey : Colors.amber,
                onPressed: _isPerformingAction ? null : abrirModalCriarNota,
                tooltip: 'Adicionar Nota',
                child: _isPerformingAction ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}