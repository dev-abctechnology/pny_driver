import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:geolocator/geolocator.dart';

import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:pny_driver/domain/datasource/romaneio_datasource.dart';
import 'package:pny_driver/domain/models/romaneio_lite_model.dart';
import 'package:pny_driver/roteiro/romaneio_details_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _date = '';
  void initialization() async {
    FlutterNativeSplash.remove();
  }

  Future<bool> isLoggedIn() async {
    var prefs = await SharedPreferences.getInstance();

    var authentication = prefs.getString('authentication');

    if (authentication == null) {
      Navigator.of(context).pushReplacementNamed('/signin');
      return false;
    } else {
      username = prefs.getString('name') ?? '';
      print(username);
      return true;
    }
  }

  String username = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _date = DateTime.now().toString();
    isLoggedIn();
    initializer();
    initialization();
  }

  initializer() async {
    var init = await initializeSharedPreferences();
    if (init) {
      initialSearch();
    }
  }

//create a disclouser dialog to show a popup to confirm if the user allow access to location services
  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Atenção'),
            content: const Text(
                'Você precisa permitir o acesso a localização para continuar'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar')),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _requestPermission();
                  },
                  child: const Text('Permitir')),
            ],
          );
        });
  }

//request permission to access location services
  Future<void> _requestPermission() async {
    try {
      await Geolocator.requestPermission();
    } on PlatformException catch (e) {
      print(e);
    }
  }

  _romaneioSelectedHandler(String id) async {
//create a loading dialog
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    var romaneio = await RomaneioDataSource().getRomaneioById(id);
    String date = DateFormat('dd/MM/yyyy').format(DateTime.parse(_date));
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RomaneioDetails(
              romaneio: romaneio,
            )));
  }

  var idcontroller = TextEditingController(text: '6125567e2212ef0ad848d7ae');
  String nome = '';

  Future<bool> initializeSharedPreferences() async {
    try {
      nome = await SharedPreferences.getInstance()
          .then((value) => value.getString('name')!);
      setState(() {});
      return true;
    } catch (e, s) {
      return false;
    }
  }

  var dataSource = RomaneioDataSource();
  bool isLoading = false;
  initialSearch() async {
//create a loading dialog

    setState(() {
      isLoading = true;
    });

    print(username);
    try {
      await dataSource.getRomaneiosLite(username).then((value) {
        romaneios = value;
        setState(() {});
      });
      if (romaneios.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Nenhum romaneio encontrado'),
        ));
      }
    } catch (e, s) {
      print('error: $e');
      print('stack: $s');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<RomaneioLite> romaneios = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' $username'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await initialSearch();
        },
        child: romaneios.length == 0
            ? ListView(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Lottie.asset(
                          'assets/empty_box.json',
                          frameBuilder: (context, child, composition) {
                            //RETURN A SHIMMER EFFECT IF THE ANIMATION IS NOT LOADED
                            if (composition == null) {
                              return CircularProgressIndicator();
                            }
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: child,
                            );
                          },
                          repeat: true,
                          frameRate: FrameRate(60),
                        ),
                      ),
                      Text(
                        isLoading == true
                            ? 'Carregando...'
                            : 'Nenhum romaneio encontrado, tente novamente mais tarde',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  ListView.builder(
                      shrinkWrap: true,
                      itemCount: romaneios.length,
                      physics: BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (BuildContext context, int index) {
                        String date = DateFormat('dd/MM/yyyy')
                            .format(DateTime.parse(_date));
                        return Card(
                          child: InkWell(
                            onTap: () {
                              _romaneioSelectedHandler(romaneios[index].id);
                            },
                            child: Column(
                              children: [
                                // card with romaneio info
                                ListTile(
                                  title: Text(
                                    'Romaneio: ' + romaneios[index].code,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                  subtitle: Text(
                                      'Data: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(romaneios[index].deliveryDate))}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      )),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  Column(
                    children: [
                      Container(
                        child: Lottie.asset(
                          'assets/romaneio.json',
                          frameBuilder: (context, child, composition) {
                            //RETURN A SHIMMER EFFECT IF THE ANIMATION IS NOT LOADED
                            if (composition == null) {
                              return CircularProgressIndicator();
                            }
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: child,
                            );
                          },
                        ),
                      ),
                      Text(
                        isLoading == true
                            ? 'Carregando...'
                            : 'Toque em um romaneio para ver mais detalhes',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Hoje',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Sair',
          ),
        ],
        currentIndex: 0,
        onTap: (int index) {
          // show a dialog asking if the user wants to logout

          if (index == 2) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Sair'),
                    content: const Text('Deseja sair?'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Não')),
                      TextButton(
                          onPressed: () async {
                            var prefs = await SharedPreferences.getInstance();
                            prefs.clear();
                            // exit the app
                            SystemNavigator.pop();
                          },
                          child: const Text('Sim')),
                    ],
                  );
                });
          }
        },
      ),
    );
  }
}

class Shimmer {
  const Shimmer._();

  static Widget fromColors({
    required Color baseColor,
    required Color highlightColor,
    Widget? child,
    double? period,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            baseColor,
            highlightColor,
            baseColor,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
