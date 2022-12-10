import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
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
                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) => Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        topRight: Radius.circular(20.0),
                      ),
                    ),
                    child: Form(
                      key: _formKeyEntregue,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: _entregueNomeController,
                              decoration: const InputDecoration(
                                  labelText: 'Nome do recebedor',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)))),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, informe o nome';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: _entregueDocumentoController,
                              decoration: const InputDecoration(
                                  labelText: 'Documento do recebedor',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)))),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
//allow only cpf or cnpj with mask

                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d{0,14}')),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor, informe o documento';
                                }

                                if (value.length < 11) {
                                  return 'CPF inválido';
                                }

                                if (value.length > 11 && value.length < 14) {
                                  return 'CNPJ inválido';
                                }

                                return null;
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: _entregueDetalhamentoController,
                              decoration: const InputDecoration(
                                  labelText: 'Detalhamento da entrega',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)))),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKeyEntregue.currentState!.validate()) {
                                  _assinatura =
                                      await _handleSignaturePageNavigation();
                                  SystemChrome.setPreferredOrientations(
                                    [
                                      DeviceOrientation.portraitUp,
                                    ],
                                  );
                                  if (_assinatura != null) {
                                    Navigator.of(context).pop();
                                    setState(() {
                                      _statusInformado = true;
                                    });
                                  }
                                }
                              },
                              child: const Text('Colher Assinatura'),
                            )
                          ]),
                    ),
                  ),
                );
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

  final _formKeyNaoEntregue = GlobalKey<FormState>();
  final _formKeyEntregue = GlobalKey<FormState>();
  final _naoEntregueController = TextEditingController();
  final _entregueNomeController = TextEditingController();
  final _entregueDocumentoController = TextEditingController();
  final _entregueDetalhamentoController = TextEditingController();
  _naoEntregueWidget() {
    // image from path to base64

    return Form(
      key: _formKeyNaoEntregue,
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
                onPressed: sendToJarvisNaoEntregue,
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

  void sendToJarvisNaoEntregue() {
    if (_formKeyNaoEntregue.currentState!.validate()) {
      //show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      try {
        String fotoBase64 =
            base64Encode(File(_foto.toString()).readAsBytesSync());
        String dateNow = DateTime.now().toIso8601String();
        //format dateNow to yyyy-MM-dd HH:mm:ss
        dateNow = dateNow.substring(0, 10) + ' ' + dateNow.substring(11, 19);

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
          statusAplicativo: 'A2',
          codigoRomaneio: codigoRomaneio,
          pedidos: pedidos,
        ))
            .then((value) async {
          developer.log('value: $value', name: 'resposta do jarvis');

          //close loading dialog
          Navigator.pop(context);

          Navigator.pop(context, true);
        });
      } catch (e) {
        developer.log('error: $e', name: 'error');
        //show snack bar with error

        //close loading dialog
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar para o jarvis'),
          ),
        );
      }
    }
  }

  void sendToJarvisEntregue() {
    //show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      String assinaturaBase64 = _assinatura.toString();
      String dateNow = DateTime.now().toIso8601String();
      //format dateNow to yyyy-MM-dd HH:mm:ss
      dateNow = dateNow.substring(0, 10) + ' ' + dateNow.substring(11, 19);

      List<PedidoEntregue> pedidos = [];
      for (var i = 0; i < cliente.pedidosDevenda.length; i++) {
        pedidos.add(PedidoEntregue(
          cliente.pedidosDevenda[i].codigo,
          assinaturaBase64,
          'A2',
          'Entregue',
          _entregueDetalhamentoController.text,
        ));
      }

      jarvisController
          .updateRomaneio(RomaneioEntregue(
        codigoCliente: cliente.codigo,
        imagemBase64: assinaturaBase64,
        dataEntrega: dateNow,
        nomeRecebedor: _entregueNomeController.text,
        documentoRecebedor: _entregueDocumentoController.text,
        courier: false,
        statusEntrega: 'Entregue',
        statusAplicativo: 'A2',
        codigoRomaneio: codigoRomaneio,
        pedidos: pedidos,
      ))
          .then((value) async {
        developer.log('value: $value', name: 'resposta do jarvis');

        //close loading dialog
        Navigator.pop(context);

        Navigator.pop(context, true);
      });
    } catch (e) {
      developer.log('error: $e', name: 'error');
      //show snack bar with error

      //close loading dialog
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar para o jarvis - $e'),
        ),
      );
    }
  }

  _entregueWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Status informado',
        ),
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
        Image.memory(
          fit: BoxFit.fitHeight,
          Uint8List.fromList(
            base64Decode(
              _assinatura.toString(),
            ),
          ),
        ),
        Text(_entregueNomeController.text),
        Text(_entregueDocumentoController.text),
        Text(_entregueDetalhamentoController.text),
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
                sendToJarvisEntregue();
              },
              child: const Text('Enviar'),
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
