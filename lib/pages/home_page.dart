import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
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

  Future<bool> isLoggedIn() async {
    var prefs = await SharedPreferences.getInstance();

    var authentication = prefs.getString('authentication');

    if (authentication == null) {
      Navigator.of(context).pushReplacementNamed('/signin');
      return false;
    } else {
      return true;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _date = DateTime.now().toString();
    isLoggedIn();
    initializeSharedPreferences();
    initialSearch();
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

  initializeSharedPreferences() async {
    nome = await SharedPreferences.getInstance()
        .then((value) => value.getString('name')!);
    setState(() {});
  }

  var dataSource = RomaneioDataSource();

  initialSearch() async {
//create a loading dialog

    try {
      await dataSource.getRomaneiosLite('EDSON').then((value) {
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
    } finally {}
  }

  List<RomaneioLite> romaneios = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecione um romaneio'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await initialSearch();
        },
        child: ListView.builder(
            itemCount: romaneios.length,
            physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.all(8),
            itemBuilder: (BuildContext context, int index) {
              String date =
                  DateFormat('dd/MM/yyyy').format(DateTime.parse(_date));
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
                          'Código: ' + romaneios[index].code,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
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
