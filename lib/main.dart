//flutter main function
import 'package:flutter/material.dart';
import 'package:pny_driver/auth/token/token_store.dart';
import 'package:pny_driver/pages/camera_page.dart';
import 'package:pny_driver/pages/home_page.dart';
import 'package:pny_driver/pages/romaneio_chegada_page.dart';
import 'package:pny_driver/pages/romaneio_details_page.dart';
import 'package:pny_driver/pages/signature_page.dart';
import 'package:provider/provider.dart';

import 'auth/pages/signin_page.dart';

void main() {
  runApp(const MyApp());
}

//
//flutter main widget
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TokenStore>(
          create: (buildContext) {
            return TokenStore();
          },
        ),
      ],
      child: MaterialApp(
        title: 'Persianas New York Driver',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/signin',
        routes: {
          '/signin': (context) => const SignIn(),
          '/': (context) => const HomePage(),
          '/romaneio': (context) => const RomaneioDetails(),
          '/chegada': (context) => const RomaneioChegada(),
          '/signature': (context) => const SignaturePage(),
          '/nao_entregue': (context) => const EntregaNaoRealizada(),
        },
      ),
    );
  }
}
