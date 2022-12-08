import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:pny_driver/domain/models/pedido_entregue.dart';
import 'package:pny_driver/domain/models/romaneio_model.dart';
import 'dart:developer' as developer;

import 'package:pny_driver/roteiro/controller/romaneio_jarvis_controllers.dart';

import '../domain/models/romaneio_custom_api_model.dart';

class RomaneioChegada extends StatefulWidget {
  const RomaneioChegada({
    super.key,
  });

  @override
  State<RomaneioChegada> createState() => _RomaneioChegadaState();
}

class _RomaneioChegadaState extends State<RomaneioChegada> {
  Future _handleSignaturePageNavigation() async {
    return await Navigator.of(context).pushNamed('/signature');
  }

  Future _handleEntregaNaoEfetuadaPageNavigation() async {
    return await Navigator.of(context).pushNamed('/nao_entregue');
  }

  Object? _foto;
  Object? _assinatura;
  bool _statusInformado = false;
  late RomaneioJarvisController jarvisController;

  _askDeliveredWidget() {
    ClienteRomaneio cliente = args['cliente'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'A entrega foi efetuada?',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(cliente.nome, style: const TextStyle(fontSize: 20)),
        Text(cliente.cnpj, style: const TextStyle(fontSize: 20)),
        Card(
          child: ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: cliente.pedidosDevenda.length,
            itemBuilder: (context, index) => Card(
              child: ListTile(
                  title: Center(
                      child: Text('Pedido de Venda ' +
                          cliente.pedidosDevenda[index].codigo)),
                  subtitle: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: cliente.pedidosDevenda[index].ctn00010.length,
                    itemBuilder: (context, innerIndex) {
                      var pedidoDeVenda =
                          cliente.pedidosDevenda[index].ctn00010[innerIndex];

                      return Card(
                        child: ListTile(
                          title: Center(child: Text(pedidoDeVenda.descricao)),
                          subtitle: Text(pedidoDeVenda.quantidade),
                        ),
                      );
                    },
                  )),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () async {
                _foto = await _handleEntregaNaoEfetuadaPageNavigation();
                SystemChrome.setPreferredOrientations(
                  [
                    DeviceOrientation.portraitUp,
                  ],
                );
                if (_foto != null) {
                  setState(() {
                    _statusInformado = true;
                  });
                }
              },
              child: const Text('Não'),
            ),
            ElevatedButton(
              onPressed: () async {
                _assinatura = await _handleSignaturePageNavigation();
                SystemChrome.setPreferredOrientations(
                  [
                    DeviceOrientation.portraitUp,
                  ],
                );
                if (_assinatura != null) {
                  setState(() {
                    _statusInformado = true;
                  });
                }
              },
              child: const Text('Sim'),
            ),
          ],
        ),
      ],
    );
  }

  _statusWidget() {
    if (_foto != null && _assinatura == null) {
      return _naoEntregueWidget();
    }
    if (_foto == null && _assinatura != null) {
      return _entregueWidget();
    }
    return const SizedBox();
  }

  final _formKey = GlobalKey<FormState>();
  final _naoEntregueController = TextEditingController();

  _naoEntregueWidget() {
    // image from path to base64

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Status informado',
          ),
          Image.file(
            height: 400.0,
            width: 400.0,
            fit: BoxFit.fitHeight,
            File(
              _foto.toString(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _statusInformado = false;
                    _foto = null;
                    _assinatura = null;
                  });
                },
                child: const Text('Alterar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String fotoBase64 =
                        base64Encode(File(_foto.toString()).readAsBytesSync());
                    String dateNow = DateTime.now().toIso8601String();
                    //format dateNow to yyyy-MM-dd HH:mm:ss
                    dateNow = dateNow.substring(0, 10) +
                        ' ' +
                        dateNow.substring(11, 19);

                    List<PedidoEntregue> pedidos = [];
                    for (var i = 0; i < cliente.pedidosDevenda.length; i++) {
                      pedidos.add(PedidoEntregue(
                        cliente.pedidosDevenda[i].codigo,
                        fotoBase64,
                        'A5',
                        'Não entregue',
                        'motivo: ${_naoEntregueController.text}',
                      ));
                    }

                    jarvisController
                        .updateRomaneio(RomaneioEntregue(
                      codigoCliente: cliente.codigo,
                      imagemBase64: fotoBase64,
                      dataEntrega: dateNow,
                      nomeRecebedor: 'Não entregue',
                      documentoRecebedor: '000.000.000-00',
                      courier: false,
                      statusEntrega: 'motivo: ${_naoEntregueController.text}',
                      statusAplicativo: 'A4',
                      codigoRomaneio: codigoRomaneio,
                      pedidos: pedidos,
                    ))
                        .then((value) {
                      developer.log('value: $value',
                          name: 'resposta do jarvis');

                      Navigator.pop(context, true);
                    });
                  }
                },
                child: Text('enviar'),
              )
            ],
          ),
          TextFormField(
            controller: _naoEntregueController,
            decoration: const InputDecoration(
              labelText: 'Explique o motivo da não entrega',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, informe o motivo da não entrega';
              }
              if (value.length < 7) {
                return 'Por favor, informe um motivo mais detalhado';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  _entregueWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Status informado',
        ),
        Image.memory(
          fit: BoxFit.fitHeight,
          Uint8List.fromList(
            base64Decode(
              _assinatura.toString(),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _statusInformado = false;
                  _foto = null;
                  _assinatura = null;
                });
              },
              child: const Text('Alterar'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _naoEntregueController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    jarvisController = RomaneioJarvisController(Dio());

    WidgetsFlutterBinding.ensureInitialized();
  }

  Map args = {};
  late ClienteRomaneio cliente;
  late String codigoRomaneio;
  _createArgs() {
    if (args.isNotEmpty) {
    } else {
      try {
        args = ModalRoute.of(context)!.settings.arguments as Map;
        cliente = args['cliente'];
        codigoRomaneio = args['codigoRomaneio'];
        print(args);
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _createArgs();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Você chegou até aqui'),
      ),
      body: SingleChildScrollView(
        child: Center(
            child: _statusInformado ? _statusWidget() : _askDeliveredWidget()),
      ),
    );
  }
}
