//flutter main function
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'package:pny_driver/auth/token/token_store.dart';
import 'package:pny_driver/config/custom_theme.dart';
import 'package:pny_driver/pages/camera_page.dart';
import 'package:pny_driver/pages/home_page.dart';
import 'package:pny_driver/pages/romaneio_chegada_page.dart';
import 'package:pny_driver/pages/signature_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(
      widgetsBinding: widgetsBinding,
    );
  }

//create a method to verify if the user has logged in or not check if the authentication String in sharedPreferences is null or not

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
        debugShowCheckedModeBanner: false,
        title: 'Persianas New York Driver',
        theme: ThemeData(
          fontFamily: 'Nunito',
          useMaterial3: false,
          brightness: Brightness.light,
          primarySwatch: Palette.customGreyDark,
        ),
        initialRoute: '/',
        routes: {
          '/signin': (context) => const SignIn(),
          '/': (context) => const HomePage(),
          '/splash': (context) => const MySplashSCreen(),
          '/chegada': (context) => const RomaneioChegada(),
          '/signature': (context) => const SignaturePage(),
          '/nao_entregue': (context) => const EntregaNaoRealizada(),
        },
      ),
    );
  }
}

class MySplashSCreen extends StatelessWidget {
  const MySplashSCreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen.withScreenRouteFunction(
      splash: Image.asset(
        'assets/splash_icon.png',
        width: MediaQuery.of(context).size.width * .4,
      ),
      splashTransition: SplashTransition.slideTransition,
      backgroundColor: Palette.persianasColor,
      duration: 1000,
      screenRouteFunction: () async {
        var prefs = await SharedPreferences.getInstance();
        var authentication = prefs.getString('authentication');
        if (authentication == null) {
          return '/signin';
        } else {
          return '/';
        }
      },
    );
  }
}
