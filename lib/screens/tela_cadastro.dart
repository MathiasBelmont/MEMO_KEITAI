import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:memoapi/api.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  void _register() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackbar('Por favor, preencha todos os campos.');
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email)) {
      _showSnackbar('Por favor, insira um e-mail válido.');
      return;
    }

    if (password.length < 6) {
      _showSnackbar('A senha deve ter pelo menos 6 caracteres.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userCreateDTO = UserCreateDTO(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    try {
      final api = UserControllerApi();
      final http.Response httpResponse = await api.createWithHttpInfo(
        userCreateDTO,
      );

      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        _showSnackbar('Cadastro realizado com sucesso!', isError: false);
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }
      } else {
        String errorMessage = 'Erro desconhecido do servidor.';
        if (httpResponse.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(httpResponse.body);
            if (errorData is Map) {
              errorMessage = errorData['message'] ??
                  errorData['error'] ??
                  errorData['detail'] ??
                  (errorData['errors'] is Map ? errorData['errors'].values.join(', ') : null) ??
                  httpResponse.body;
            } else if (errorData is String) {
              errorMessage = errorData;
            } else {
              errorMessage = httpResponse.body;
            }
          } catch (e) {
            errorMessage = httpResponse.body;
          }
        } else {
          errorMessage = 'Erro ${httpResponse.statusCode} sem mensagem adicional.';
        }

        String displayMessage;
        if (httpResponse.statusCode == 400) {
          if (errorMessage.toLowerCase().contains("email") && errorMessage.toLowerCase().contains("exist")) {
            displayMessage = 'Este e-mail já está cadastrado.';
          } else {
            displayMessage = 'Dados inválidos. Verifique os campos e tente novamente.';
          }
        } else if (httpResponse.statusCode == 409) {
          displayMessage = 'Este e-mail já está cadastrado.';
        }
        else {
          String sanitizedApiMessage = errorMessage.length > 150
              ? "${errorMessage.substring(0, 150)}..."
              : errorMessage;
          displayMessage = 'Erro ao cadastrar (${httpResponse.statusCode}): $sanitizedApiMessage';
        }
        _showSnackbar(displayMessage);
      }
    } on ApiException catch (e) {
      String displayMessage = 'Erro na comunicação com a API.';
      if (e.message != null && e.message!.isNotEmpty) {
        try {
          final errorBody = jsonDecode(e.message!);
          if (errorBody is Map && errorBody['message'] != null) {
            displayMessage = 'Erro na API: ${errorBody['message']}';
          } else {
            displayMessage = 'Erro na API: ${e.message}';
          }
        } catch (_) {
          displayMessage = 'Erro na API: ${e.message}';
        }

        if (e.code != 0) {
          displayMessage += ' (Código: ${e.code})';
          if (e.code == 409) displayMessage = 'Este e-mail já está cadastrado.';
        }
      } else if (e.code != 0) {
        displayMessage = 'Erro na API (Código: ${e.code}).';
        if (e.code == 409) displayMessage = 'Este e-mail já está cadastrado.';
      }
      _showSnackbar(displayMessage);
    } catch (e) {
      _showSnackbar('Ocorreu um erro ao tentar fazer o cadastro. Verifique sua conexão ou tente novamente.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: Colors.amber,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported, size: 120);
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Cadastro',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _nameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: 'Nome Completo',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Cadastrar'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: const Text(
                  'Já tem uma conta? Faça login',
                  style: TextStyle(color: Colors.amber),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}