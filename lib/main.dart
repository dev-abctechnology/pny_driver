//flutter main function
import 'package:flutter/material.dart';
import 'package:pny_driver/auth/token/token_store.dart';
import 'package:pny_driver/pages/signature_page.dart';
import 'package:provider/provider.dart';

import 'auth/pages/signin_page.dart';

void main() => runApp(MyApp());

//
//flutter main widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TokenStore>(
          create: (_) => TokenStore(),
        ),
      ],
      child: MaterialApp(
        title: 'Persianas New York Driver',
        theme:
            ThemeData(primarySwatch: Colors.green, brightness: Brightness.dark),
        home: SignIn(),
      ),
    );
  }
}
