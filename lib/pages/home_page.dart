import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:pny_driver/domain/datasource/romaneio_datasource.dart';
import 'package:pny_driver/domain/models/romaneio_lite_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _date = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _date = DateTime.now().toString();
  }

  _romaneioSelectedHandler() async {
//create a loading dialog
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    var romaneio =
        await RomaneioDataSource().getRomaneioById('6384db3dd8606813bd6c23d1');
    String date = DateFormat('dd/MM/yyyy').format(DateTime.parse(_date));
    Navigator.of(context).pop();
    Navigator.pushNamed(context, '/romaneio', arguments: {
      'romaneio': romaneio,
      'date': date,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Romaneios - $_date'),
      ),
      body: SingleChildScrollView(
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: 1,
              padding: const EdgeInsets.all(8),
              itemBuilder: (BuildContext context, int index) {
                var romaneioLite = RomaneioLite(
                  id: '6384db3dd8606813bd6c23d1',
                  code: '16294',
                  driver: 'Motorista',
                  deliveryDate: '2022-11-28',
                );
                String date =
                    DateFormat('dd/MM/yyyy').format(DateTime.parse(_date));
                return Card(
                  child: InkWell(
                    onTap: _romaneioSelectedHandler,
                    child: Column(
                      children: [
                        // card with romaneio info
                        ListTile(
                          title: Text(
                            'Código: ' + romaneioLite.code,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          subtitle: Text(
                              'Data: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(romaneioLite.deliveryDate))}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                      ],
                    ),
                  ),
                );
              })),
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
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: 0,
        onTap: (int index) {
          print('index: $index');
        },
      ),
    );
  }
}
