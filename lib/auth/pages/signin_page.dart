import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:pny_driver/auth/token/token_store.dart';
import 'package:pny_driver/config/custom_theme.dart';
import 'package:pny_driver/roteiro/controller/romaneio_jarvis_controllers.dart';

import '../auth_repository.dart';
import '../usecases/signin.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController =
      TextEditingController(text: '');
  late final TextEditingController _passwordController =
      TextEditingController(text: '');
  final _authUseCase = AuthUseCase(Dio());
  bool _isLoading = false;
  bool _obscurePassword = true;

  void storeToken(String token) {
    print(token);
    Provider.of<TokenStore>(context, listen: false).setToken(token);
  }

  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  void navigateHome(context) {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    const SizedBox heightBox = SizedBox(height: 100);

    return Scaffold(
      body: Container(
        color: Palette.persianasColor.shade400.withAlpha(230),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(180),
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/icon_driver.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  heightBox,
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            key: const Key('username'),
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Usuário',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Digite seu usuário';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            key: const Key('password'),
                            obscureText: _obscurePassword,
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: _obscurePassword
                                    ? const Icon(Icons.visibility_off)
                                    : const Icon(Icons.visibility),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Digite sua senha';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _isLoading
                            ? const CircularProgressIndicator()
                            : SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      var result = await _authUseCase.signIn(
                                        AuthSignInParams(
                                          email:
                                              'PRD-QIB4:${_emailController.text}',
                                          password: _passwordController.text,
                                        ),
                                      );

                                      setState(() {
                                        _isLoading = false;
                                      });

                                      if (result.isRight) {
                                        storeToken(result.right);
                                        navigateHome(context);
                                      } else {
                                        showErrorSnackBar(result.left.message);
                                      }
                                    }
                                  },
                                  child: const Text('Entrar'),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      launchUrl(
                        Uri.parse(
                            'https://abctechnology.com.br/privacy_pny_driver.html'),
                        mode: LaunchMode.externalNonBrowserApplication,
                        webOnlyWindowName: '_blank',
                      );
                    },
                    child: const Text(
                      'Política de Privacidade',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
