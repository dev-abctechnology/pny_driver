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
  final _emailController = TextEditingController(text: '05664267000105');
  final _passwordController = TextEditingController(text: '@BCtech2022@');
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
    //create a login screen with a form and a button to submit the form and login the user
    // the page musth have a background image and a logo on the top of the page and the forms below must be in a container with a white background and rounded corners
    // the form must have a text field for the email and a text field for the password
    // the form must have a button to submit the form
    // the form must have a button to navigate to the signup page

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/background.png',
            ),
            // change opacity to 0.2
            colorFilter: ColorFilter.mode(Colors.black87, BlendMode.darken),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 100,
                ),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/images/logo.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
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
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: 'Senha',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Digite sua senha';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        _isLoading
                            ? CircularProgressIndicator()
                            : Container(
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
                                        // ignore: use_build_context_synchronously

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
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold();
  }
}
