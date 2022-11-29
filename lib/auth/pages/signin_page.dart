import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:pny_driver/auth/token/token_store.dart';
import 'package:provider/provider.dart';

import '../../pages/home_page.dart';
import '../auth_repository.dart';
import '../usecases/signin.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authUseCase = AuthUseCase(Dio());
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

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

  navigateHome(context) {
    return Navigator.of(context).pushNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter some text';
                  }
                  return null;
                },
              ),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });

                      var result = await _authUseCase.signIn(
                        AuthSignInParams(
                          email: 'PRD-QIB4:${_emailController.text}',
                          password: _passwordController.text,
                        ),
                      );
                      setState(() {
                        _isLoading = false;
                      });
                      if (result.isRight) {
                        storeToken(result.right);
                        navigateHome(context);
                        // ignore: use_build_context_synchronously

                      } else {
                        showErrorSnackBar(result.left.message);
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
