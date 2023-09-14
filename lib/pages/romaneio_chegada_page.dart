// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:pny_driver/domain/models/pedido_entregue.dart';
import 'package:pny_driver/domain/models/romaneio_model.dart';
import 'package:pny_driver/pages/widgets/spacer_widget.dart';
import 'package:pny_driver/roteiro/controller/romaneio_jarvis_controllers.dart';
import 'package:pny_driver/utils/cpf_validator.dart';

import '../domain/models/romaneio_custom_api_model.dart';
import 'delivery_details_page.dart';

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
  bool _isCollapsed = true;
  _askDeliveredWidget() {
    ClienteRomaneio cliente = args['cliente'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeIn,
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
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isCollapsed
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                ListTile(
                  title: Text(
                    cliente.nome,
                    style: const TextStyle(fontSize: 20),
                  ),
                  subtitle:
                      Text(cliente.cnpj, style: const TextStyle(fontSize: 18)),
                ),
                ListTile(
                  title: Text(cliente.telefoneEntrega,
                      style: const TextStyle(fontSize: 18)),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    // setState(() {
                    //   _isCollapsed = !_isCollapsed;
                    // });

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            DeliveryDetails(clienteRomaneio: cliente)));
                  },
                  child: const Text('Ver pedidos'),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
            secondChild: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                ListTile(
                  title: Text(
                    cliente.nome,
                    style: const TextStyle(fontSize: 20),
                  ),
                  subtitle:
                      Text(cliente.cnpj, style: const TextStyle(fontSize: 18)),
                ),
                ListTile(
                  title: Text(cliente.telefoneEntrega,
                      style: const TextStyle(fontSize: 18)),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ListView.separated(
                      separatorBuilder: (context, index) => const Divider(),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: cliente.pedidosDevenda.length,
                      itemBuilder: (context, index) {
                        final pedido = cliente.pedidosDevenda[index];

                        return ListTile(
                          title: Text(
                            'pedido: ${pedido.codigo}',
                          ),
                          subtitle: ListView.separated(
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              final item = pedido.ctn00010[index];
                              return ListTile(
                                title: Text(
                                  item.codigoProduto,
                                ),
                                subtitle: Text(
                                  item.descricao,
                                ),
                                trailing: Text(
                                  '${item.quantidade}x',
                                ),
                              );
                            },
                            itemCount: pedido.ctn00010.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isCollapsed = !_isCollapsed;
                    });
                  },
                  child: const Text('Ocultar pedidos'),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
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
          decoration: const BoxDecoration(
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
                const Center(
                    child: Text('Entrega efetuada',
                        style: TextStyle(fontSize: 20))),
                const SizedBox(
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
                const SpacerBox(),
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

                    if (value.length == 18) {
                      if (!CNPJValidator.isValid(value)) {
                        return 'CNPJ inválido';
                      }
                    }

                    return null;
                  },
                ),
                const SpacerBox(),
                TextFormField(
                  controller: _entregueDetalhamentoController,
                  decoration: const InputDecoration(
                      labelText: 'Detalhamento da entrega',
                      border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0)))),
                ),
                const SpacerBox(),
                SizedBox(
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
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
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
            const SizedBox(
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
                  child: const Text('Enviar'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> sendToJarvisNaoEntregue() async {
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
        dateNow = '${dateNow.substring(0, 10)} ${dateNow.substring(11, 19)}';

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

        await jarvisController
            .updateRomaneio(RomaneioEntregue(
          codigoCliente: cliente.codigo,
          imagemBase64: fotoBase64,
          dataEntrega: dateNow,
          nomeRecebedor: 'Não entregue',
          documentoRecebedor: '000.000.000-00',
          courier: false,
          detalhamentoRomaneio: '',
          statusEntrega: 'motivo: ${_naoEntregueController.text}',
          statusAplicativo: 'A2',
          codigoRomaneio: codigoRomaneio,
          pedidos: pedidos,
        ))
            .then((value) async {
//verify if the romaneio was updated by either

          value.fold((error) {
            print(error);
            //show snack bar with error
            throw error;
          }, (response) {
            developer.log('value: $response',
                name: 'resposta do jarvis', error: response);

            //close loading dialog
            Navigator.pop(context);

            Navigator.pop(context, true);
          });
        });
      } catch (e) {
        developer.log('error: $e', name: 'error');
        //show snack bar with error

        //close loading dialog
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('Erro: $e'),
          ),
        );
      }
    }
  }

  List<PedidoEntregue> pedidos = [];
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
      dateNow = '${dateNow.substring(0, 10)} ${dateNow.substring(11, 19)}';

//format dateNow to dd-MM-yyyy às HH:mm
      var dataHoraEntrega =
          '${dateNow.substring(8, 10)}/${dateNow.substring(5, 7)}/${dateNow.substring(0, 4)} às ${dateNow.substring(11, 16)}';

      pedidos = [];
      for (var i = 0; i < cliente.pedidosDevenda.length; i++) {
        pedidos.add(PedidoEntregue(
          cliente.pedidosDevenda[i].codigo,
          assinaturaBase64,
          _pedidosEntregues[i] ? 'A3' : 'A4',
          _pedidosEntregues[i] ? 'Entregue' : 'Entregue com restrição',
          _pedidosEntregues[i]
              ? 'Entregue com sucesso às $dataHoraEntrega'
              : 'Entregue com restrição às $dataHoraEntrega\nDetalhamento: ${_detalhamentoControllers[i].text}',
        ));
      }

      print(pedidos.map((e) => e.detalhamento).toList());

      jarvisController
          .updateRomaneio(RomaneioEntregue(
        codigoCliente: cliente.codigo,
        imagemBase64: assinaturaBase64,
        dataEntrega: dateNow,
        nomeRecebedor: _entregueNomeController.text,
        documentoRecebedor: _entregueDocumentoController.text,
        detalhamentoRomaneio: _entregueDetalhamentoController.text,
        courier: false,
        statusEntrega: 'Entregue',
        statusAplicativo: 'A2',
        codigoRomaneio: codigoRomaneio,
        pedidos: pedidos,
      ))
          .then((value) async {
        developer.log('value: $value', name: 'resposta do jarvis');
        List<String> codigoPedidos = [];
        for (var i = 0; i < cliente.pedidosDevenda.length; i++) {
          codigoPedidos.add(cliente.pedidosDevenda[i].codigo);
        }
        jarvisController.executePipeline(codigoPedidos).then((value) {
          developer.log('value: $value', name: 'resposta da GHS');
        });
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

  final _restricaoKey = GlobalKey<FormState>();
  _entregueWidget() {
    return Form(
      key: _restricaoKey,
      child: Column(
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
            title: Text('Recebido por: ${_entregueNomeController.text}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Documento: ${_entregueDocumentoController.text}'),
                Text(_entregueDetalhamentoController.text == ''
                    ? 'Sem observações'
                    : _entregueDetalhamentoController.text),
              ],
            ),
          ),
          const Divider(),
          const Text(
            'Marque os pedidos entregues sem restrições',
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          // grid view with checkbox for every cliente.pedidosDevenda
          ListView.separated(
            separatorBuilder: (context, index) {
              return const Divider();
            },
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: cliente.pedidosDevenda.length,
            itemBuilder: (BuildContext context, int index) {
              return CheckboxListTile(
                title: Column(
                  children: [
                    _pedidosEntregues[index]
                        ? Text(
                            '${cliente.pedidosDevenda[index].codigo} - Entregue sem restrições')
                        : TextFormField(
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty && !_pedidosEntregues[index]) {
                                return 'Informe o motivo da restrição';
                              }
                              return null;
                            },
                            controller: _detalhamentoControllers[index],
                            decoration: InputDecoration(
                              labelText:
                                  'Informe a restrição do pedido ${cliente.pedidosDevenda[index].codigo}',
                              border: const OutlineInputBorder(),
                            ),
                          )
                  ],
                ),
                value: _pedidosEntregues[index],
                onChanged: (bool? value) {
                  setState(() {
                    _pedidosEntregues[index] = value!;
                  });
                },
              );
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
                onPressed: () {
                  //show dialog confirm send
                  if (_restricaoKey.currentState!.validate()) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                              'Tem certeza que deseja confirmar a entrega?'),
                          content: const Text(
                              'Ao enviar, não será possível alterar os dados informados.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                sendToJarvisEntregue();
                              },
                              child: const Text('Enviar'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: const Text('Enviar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _naoEntregueController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    jarvisController = RomaneioJarvisController(Dio());

    WidgetsFlutterBinding.ensureInitialized();
  }

  List<bool> _pedidosEntregues = [];
  List<TextEditingController> _detalhamentoControllers = [];
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
        _pedidosEntregues =
            List.generate(cliente.pedidosDevenda.length, (index) => false);
        _detalhamentoControllers = List.generate(
            cliente.pedidosDevenda.length, (index) => TextEditingController());
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
        title: Text('Romaneio $codigoRomaneio'),
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
