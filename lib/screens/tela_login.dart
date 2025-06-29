import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:memoapi/api.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackbar('Por favor, preencha todos os campos.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userLoginDTO = UserLoginDTO(email: email, password: password);

    try {
      final api = UserControllerApi();
      final http.Response httpResponse = await api.loginWithHttpInfo(
        userLoginDTO,
      );

      if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
        if (httpResponse.body.isNotEmpty) {
          try {
            final Map<String, dynamic> responseData = jsonDecode(
              httpResponse.body,
            );
            final dynamic userIdDynamic = responseData['id'];
            int? userId;

            if (userIdDynamic is int) {
              userId = userIdDynamic;
            } else if (userIdDynamic is String) {
              userId = int.tryParse(userIdDynamic);
            }

            if (userId != null) {
              if (mounted) {
                Navigator.pushReplacementNamed(
                  context,
                  '/notas',
                  arguments: userId,
                );
              }
            } else {
              _showErrorSnackbar(
                'Não foi possível obter o ID do usuário da resposta.',
              );
            }
          } catch (e) {
            _showErrorSnackbar('Resposta do servidor inválida.');
          }
        } else {
          _showErrorSnackbar('Login bem-sucedido, mas sem dados retornados.');
        }
      } else {
        String errorMessage = 'Erro desconhecido do servidor.';
        if (httpResponse.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(httpResponse.body);
            if (errorData is Map) {
              errorMessage =
                  errorData['message'] ??
                      errorData['error'] ??
                      errorData['detail'] ??
                      httpResponse.body;
            } else {
              errorMessage = httpResponse.body;
            }
          } catch (e) {
            errorMessage = httpResponse.body;
          }
        } else {
          errorMessage =
          'Erro ${httpResponse.statusCode} sem mensagem adicional.';
        }

        String displayMessage;
        if (httpResponse.statusCode == 401) {
          displayMessage = 'Credenciais inválidas. Por favor, tente novamente.';
        } else if (httpResponse.statusCode == 404){
          displayMessage = 'Usuário não encontrado ou informações incorretas.';
        } else {
          String sanitizedApiMessage =
          errorMessage.length > 100
              ? "${errorMessage.substring(0, 100)}..."
              : errorMessage;
          displayMessage =
          'Erro na API (${httpResponse.statusCode}): $sanitizedApiMessage';
        }
        _showErrorSnackbar(displayMessage);
      }
    } on ApiException catch (e) {
      String displayMessage = 'Erro na comunicação com a API.';
      if (e.message != null && e.message!.isNotEmpty) {
        try {
          final errorBody = jsonDecode(e.message!);
          if (errorBody is Map && errorBody['message'] != null) {
            displayMessage = 'Erro na API: ${errorBody['message']}';
          } else if (errorBody is Map && errorBody['detail'] != null) {
            displayMessage = 'Erro na API: ${errorBody['detail']}';
          }
          else {
            displayMessage = 'Erro na API: ${e.message}';
          }
        } catch (_) {
          displayMessage = 'Erro na API: ${e.message}';
        }

        if (e.code != 0) {
          displayMessage += ' (Código: ${e.code})';
        }
      } else if (e.code != 0) {
        displayMessage = 'Erro na API (Código: ${e.code}).';
      }
      _showErrorSnackbar(displayMessage);
    } catch (e) {
      String displayMessage =
          'Ocorreu um erro ao tentar fazer login. Verifique sua conexão ou tente novamente.';
      if (e is FormatException) {
        displayMessage = 'Erro ao processar a resposta do servidor.';
      }
      _showErrorSnackbar(displayMessage);
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 150,
                height: 150,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported, size: 150);
                },
              ),
              const SizedBox(height: 32),
              const SizedBox(height: 24),
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
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/cadastro');
                },
                child: const Text(
                  'Não tem uma conta? Cadastre-se',
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