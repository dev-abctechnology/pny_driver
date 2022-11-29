import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../domain/datasource/romaneio_datasource.dart';
import '../domain/models/romaneio_model.dart';

class RomaneioDetails extends StatefulWidget {
  const RomaneioDetails({super.key});

  @override
  State<RomaneioDetails> createState() => _RomaneioDetailsState();
}

class _RomaneioDetailsState extends State<RomaneioDetails> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ??
        <String, dynamic>{}) as Map;
    print(arguments);
    final romaneio = arguments['romaneio'] as Romaneio;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Romaneio'),
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          romaneio == null
              ? Text('Romaneio is null')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: romaneio.data.clientesRomaneio.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (BuildContext context, int index) {
                    return ExpandableRomaneioClienteWidget(
                        cliente: romaneio.data.clientesRomaneio[index]);
                  },
                ),
        ],
      )),
    );
  }
}

class ExpandableRomaneioClienteWidget extends StatefulWidget {
  final ClienteRomaneio cliente;

  const ExpandableRomaneioClienteWidget({super.key, required this.cliente});

  @override
  State<ExpandableRomaneioClienteWidget> createState() =>
      _ExpandableRomaneioClienteWidgetState();
}

class _ExpandableRomaneioClienteWidgetState
    extends State<ExpandableRomaneioClienteWidget> {
  bool _expanded = false;

  void _handleExpand() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    EnderecoTemplate enderecoUm = widget.cliente.enderecos.first;
    ClienteRomaneio cliente = widget.cliente;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: _expanded
          ? Card(
              child: InkWell(
                onTap: () {
                  // Navigator.of(context).pushNamed('/chegada');
                  _handleExpand();
                },
                child: Column(
                  children: [
                    ListTile(
                      subtitle: Text(cliente.nome),
                      title: Text(
                        '${enderecoUm.logradouro!}, ${enderecoUm.numero!} - ${enderecoUm.bairro!} - ${enderecoUm.cidade!}',
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      itemCount: cliente.pedidosDevenda.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        var Pedido = cliente.pedidosDevenda[index];
                        return Card(
                          child: Column(
                            children: [
                              ListTile(
                                title: Text('pedido: ' + Pedido.codigo),
                                subtitle: Text('itens: ' +
                                    Pedido.ctn00010.length.toString()),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : Container(
              child: TextButton(
                  onPressed: _handleExpand,
                  child: Card(
                      child: ListTile(
                          title: Text(
                              'Nome: ' + cliente.enderecos.first.logradouro!),
                          subtitle: Text('código: ' + cliente.codigo))))),
    );
  }
}
