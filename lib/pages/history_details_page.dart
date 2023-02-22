import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:pny_driver/domain/models/romaneio_model.dart';

import '../domain/datasource/romaneio_datasource.dart';

class HistoryDetails extends StatefulWidget {
  final String romaneioId;

  const HistoryDetails({super.key, required this.romaneioId});

  @override
  State<HistoryDetails> createState() => _HistoryDetailsState();
}

class _HistoryDetailsState extends State<HistoryDetails> {
  final romaneioDataSource = RomaneioDataSource();

//create a value notifier to hold the romaneio
  final romaneio = ValueNotifier<Romaneio?>(null);

  @override
  void initState() {
    super.initState();
    loadRomaneio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Romaneio'),
      ),
      body: AnimatedBuilder(
        animation: romaneio,
        builder: (context, child) {
          if (romaneio.value == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final listaClientes = romaneio.value!.data.clientesRomaneio;
          final dataCriacao = DateTime.parse(romaneio.value!.data.dataCriacao!);
          final entregaPrevista =
              DateTime.parse(romaneio.value!.data.entregaPrevista!);
          final pattern = [dd, '/', mm, '/', yyyy];
          final status = [
            'Aguardando',
            'A coletar',
            'Em trânsito',
            'Entregue',
            'Entregue C/ Restrição',
          ];
          return ListView(
            children: [
              ListTile(title: Text('Romaneio: ${romaneio.value!.code}')),
              ListTile(
                  title: Text(
                      'Status: ${status[romaneio.value!.data.statusApp.length]}')),
              ListTile(
                  title: Text(
                      'data de criação: ${formatDate(entregaPrevista, pattern)}')),
              ListTile(
                  title: Text(
                      'Entrega prevista: ${formatDate(dataCriacao, pattern)}')),
              const Divider(),
              ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => const Divider(),
                  shrinkWrap: true,
                  itemCount: listaClientes.length,
                  itemBuilder: (context, index) {
                    final cliente = listaClientes[index];
                    return InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return DraggableScrollableSheet(
                                initialChildSize: 0.5,
                                minChildSize: 0.5,
                                maxChildSize: 1,
                                expand: false,
                                builder: (context, controller) => Container(
                                  color: Colors.white,
                                  child: ListView(
                                    controller: controller,
                                    children: [
                                      ListTile(
                                          title: Text('Nome: ${cliente.nome}')),
                                      ListTile(
                                          title: Text('CNPJ: ${cliente.cnpj}')),
                                      ListView.separated(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          final item =
                                              cliente.pedidosDevenda[index];
                                          return ListTile(
                                            title:
                                                Text('Pedido: ${item.codigo}'),
                                            subtitle: ListView.builder(
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                final itemPedido =
                                                    item.ctn00010[index];
                                                return ListTile(
                                                  title: Text(
                                                      'Produto: ${itemPedido.descricao}'),
                                                  subtitle: Text(
                                                      'Quantidade: ${itemPedido.quantidade}'),
                                                );
                                              },
                                              itemCount: item.ctn00010.length,
                                              shrinkWrap: true,
                                            ),
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                            const Divider(),
                                        itemCount:
                                            cliente.pedidosDevenda.length,
                                        shrinkWrap: true,
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: ListTile(
                        title: Text(cliente.nome),
                        subtitle: Text(cliente.cnpj),
                        leading: cliente.entregue
                            ? const Icon(
                                Icons.check,
                                color: Colors.green,
                              )
                            : const Icon(Icons.close, color: Colors.red),
                      ),
                    );
                  })
            ],
          );
        },
      ),
    );
  }

  loadRomaneio() async {
    try {
      final romaneio =
          await romaneioDataSource.getRomaneioById(widget.romaneioId);
      this.romaneio.value = romaneio;
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }
}
