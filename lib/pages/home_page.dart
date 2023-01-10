// ignore_for_file: use_build_context_synchronously, avoid_print

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

import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    super.initState();

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

  Future<void> _requestPermission() async {
    try {
      await Geolocator.requestPermission();
    } on PlatformException catch (e) {
      print(e);
    }
  }

  bool _hasPermission = false;

  Future<bool> _checkPermission() async {
    try {
      _hasPermission = await Geolocator.checkPermission() ==
              LocationPermission.always ||
          await Geolocator.checkPermission() == LocationPermission.whileInUse;
      setState(() {});
      print(_hasPermission);
      return _hasPermission;
    } on PlatformException catch (e) {
      print(e);
      return false;
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
      var prefs = await SharedPreferences.getInstance();

      if (prefs.getString('name') == null) {
        return false;
      } else {
        username = prefs.getString('name')!;
        print(username);
        return true;
      }
    } catch (e, s) {
      print('error: $e');
      print('stack: $s');
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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Nenhum romaneio encontrado'),
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

  PageController pageController = PageController(initialPage: 0);
  int indexPage = 0;

  Widget pageViewWidget() {
    return PageView(
      controller: pageController,
      onPageChanged: (index) {
        setState(() {
          indexPage = index;
        });
      },
      children: [
        todayPage(),
        HistoryPage(),
        logoutPage(),
      ],
    );
  }

  Widget logoutPage() {
    return Container(
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Lottie.asset('assets/exit.json', repeat: false),
          const SizedBox(
            height: 20,
          ),
          TextButton(
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Desconectar'),
                    content: Text('Deseja realmente desconectar?'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();

                            pageController.animateToPage(0,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                            setState(() {
                              indexPage = 0;
                            });
                          },
                          child: Text('Não')),
                      TextButton(
                          onPressed: () async {
                            var prefs = await SharedPreferences.getInstance();
                            prefs.clear();
                            Navigator.of(context).pop();
                            Navigator.of(context)
                                .pushReplacementNamed('/signin');
                          },
                          child: Text('Sim')),
                    ],
                  );
                },
              );
            },
            child: const Text('Desconectar'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(' $username'),
      ),
      body: pageViewWidget(),
      bottomNavigationBar: bottomNav(),
    );
  }

  BottomNavigationBar bottomNav() {
    return BottomNavigationBar(
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
      currentIndex: indexPage,
      onTap: (int index) {
        setState(() {
          indexPage = index;
          pageController.animateToPage(index,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut);
        });
      },
    );
  }

  Widget todayPage() {
    return RefreshIndicator(
      onRefresh: () async {
        await initialSearch();
      },
      child: romaneios.isEmpty
          ? ListView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 100),
                      alignment: Alignment.center,
                      child: Lottie.asset(
                        isLoading == true
                            ? 'assets/searching.json'
                            : 'assets/empty_box.json',
                        frameBuilder: (context, child, composition) {
                          //RETURN A SHIMMER EFFECT IF THE ANIMATION IS NOT LOADED
                          if (composition == null) {
                            return const CircularProgressIndicator();
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
                      style: const TextStyle(
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
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: InkWell(
                          onTap: () async {
                            var permission = await _checkPermission();
                            if (permission == true) {
                              _romaneioSelectedHandler(romaneios[index].id);
                            } else {
                              showLocationPermissionDialog();
                            }
                          },
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  'Romaneio: ${romaneios[index].code}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                subtitle: Text(
                                    'Data: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(romaneios[index].deliveryDate))}',
                                    style: const TextStyle(
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
                        isLoading == true
                            ? 'assets/searching.json'
                            : 'assets/romaneio.json',
                        frameBuilder: (context, child, composition) {
                          if (composition == null) {
                            return const CircularProgressIndicator();
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
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
    );
  }

  showLocationPermissionDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Permissão de localização'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '"Persianas New York: Entregas" usa sua localização para:',
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: const [
                    Icon(
                      Icons.circle,
                      color: Colors.grey,
                      size: 10,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        'Determinar sua localização atual para que você possa ver a rota até os clientes.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: const [
                    Icon(
                      Icons.warning_amber_outlined,
                      color: Colors.orange,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        'Sua localização só estará em uso quando o aplicativo estiver aberto ou quando você estiver em trânsito e colocar o apliativo em segundo plano.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: const [
                    Icon(
                      Icons.close_rounded,
                      color: Colors.green,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        'Quando você fechar o aplicativo, fique tranquilo, sua localização não será utilizada.',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.do_disturb,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'Não permitir',
                    style: TextStyle(color: Colors.red),
                  )),
              //textButton with Icon and Text
              TextButton.icon(
                  onPressed: () async {
                    await _requestPermission().then((value) {
                      _checkPermission().then((value) {
                        if (value == true) {
                          Navigator.of(context).pop();
                        }
                      });
                    });
                  },
                  icon: const Icon(
                    Icons.location_on,
                    color: Colors.green,
                  ),
                  label: const Text(
                    'Permitir',
                    style: TextStyle(color: Colors.green),
                  ))
            ],
          );
        });
  }
}
