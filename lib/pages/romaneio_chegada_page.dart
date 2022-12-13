import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:brasil_fields/brasil_fields.dart';
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
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              ListTile(
                title: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      cliente.nome,
                    )),
                subtitle:
                    Text(cliente.cnpj, style: const TextStyle(fontSize: 20)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    child: const Text(
                      'Pedidos: ',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: cliente.pedidosDevenda.length,
                      itemBuilder: (context, index) => ListTile(
                        title: Text(
                          cliente.pedidosDevenda[index].codigo,
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'A entrega foi efetuada?',
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: entregaEfetuadaBottomSheet,
                    child: const Text('Sim'),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  void entregaEfetuadaBottomSheet() async {
    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: MediaQuery.of(context).viewInsets,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKeyEntregue,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                Center(
                    child: Text('Entrega efetuada',
                        style: TextStyle(fontSize: 20))),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _entregueNomeController,
                  decoration: const InputDecoration(
                      labelText: 'Nome do recebedor',
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0)))),
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
                      labelText: 'Documento do recebedor (CPF ou CNPJ)',
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0)))),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    //allow only cpf or cnpj with mask
                    FilteringTextInputFormatter.digitsOnly,
                    CpfOuCnpjFormatter()
                    //auto mask cpf or cnpj when typing
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe o documento';
                    }

                    if (value.length < 14) {
                      return 'CPF inválido';
                    }

                    if (value.length > 14 && value.length < 18) {
                      return 'CNPJ inválido';
                    }

                    if (value.length == 14) {
                      if (!CPF.isValid(value)) {
                        return 'CPF inválido';
                      }
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
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0)))),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () async {
                      if (_formKeyEntregue.currentState!.validate()) {
                        _assinatura = await _handleSignaturePageNavigation();
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
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKeyNaoEntregue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 400,
              width: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                image: DecorationImage(
                  image: FileImage(
                    File(
                      _foto.toString(),
                    ),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _naoEntregueController,
              decoration: const InputDecoration(
                labelText: 'Explique o motivo da não entrega',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      _statusInformado = false;
                      _foto = null;
                      _assinatura = null;
                    });
                  },
                  child: const Text('Voltar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: sendToJarvisNaoEntregue,
                  child: Text('Enviar'),
                )
              ],
            ),
          ],
        ),
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
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              border: //rounded border
                  Border.all(
                color: Colors.black,
                width: 1,
              ),
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: // Image from base64 string
                    MemoryImage(
                  base64Decode(_assinatura.toString()),
                ),
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
        ),
        ListTile(
          title: Text('Recebido por: ' + _entregueNomeController.text),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Documento: ' + _entregueDocumentoController.text),
              Text(_entregueDetalhamentoController.text == ''
                  ? 'Sem detalhamento'
                  : _entregueDetalhamentoController.text),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                setState(() {
                  _statusInformado = false;
                  _foto = null;
                  _assinatura = null;
                });
              },
              child: const Text('Voltar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
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

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    _createArgs();
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Romaneio ${codigoRomaneio}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
                child:
                    _statusInformado ? _statusWidget() : _askDeliveredWidget()),
          ],
        ),
      ),
    );
  }
}

class CNPJ {
  static String mask(String value) {
    return value
        .replaceAllMapped(
          RegExp(r'(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})'),
          (match) =>
              '${match[1]}.${match[2]}.${match[3]}/${match[4]}-${match[5]}',
        )
        .replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String unmask(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static bool isValid(String value) {
    if (value.isEmpty) return false;

    final unmasked = unmask(value);
    if (unmasked.length != 14) return false;

    final numbers = unmasked.split('').map(int.parse).toList();

    var sum = 0;
    for (var i = 0; i < 12; i++) {
      sum += numbers[i] * (13 - (i + 1));
    }

    var result = (sum % 11);
    if (result < 2) {
      result = 0;
    } else {
      result = 11 - result;
    }

    if (result != numbers[12]) return false;

    sum = 0;
    for (var i = 0; i < 13; i++) {
      sum += numbers[i] * (14 - (i + 1));
    }

    result = (sum % 11);
    if (result < 2) {
      result = 0;
    } else {
      result = 11 - result;
    }

    if (result != numbers[13]) return false;

    return true;
  }
}

class CPF {
  static String mask(String value) {
    return value
        .replaceAllMapped(
          RegExp(r'(\d{3})(\d{3})(\d{3})(\d{2})'),
          (match) => '${match[1]}.${match[2]}.${match[3]}-${match[4]}',
        )
        .replaceAll(RegExp(r'[^0-9]'), '');
  }

  static String unmask(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  static bool isValid(String value) {
    if (value.isEmpty) return false;

    final unmasked = unmask(value);
    if (unmasked.length != 11) return false;

    final numbers = unmasked.split('').map(int.parse).toList();
    final firstDigit = numbers[9];
    final secondDigit = numbers[10];

    var sum = 0;
    for (var i = 0; i < 9; i++) {
      sum += numbers[i] * (10 - i);
    }

    var mod = sum % 11;
    if (mod < 2) {
      mod = 0;
    } else {
      mod = 11 - mod;
    }

    if (mod != firstDigit) return false;

    sum = 0;
    for (var i = 0; i < 10; i++) {
      sum += numbers[i] * (11 - i);
    }

    mod = sum % 11;
    if (mod < 2) {
      mod = 0;
    } else {
      mod = 11 - mod;
    }

    return mod == secondDigit;
  }
}
