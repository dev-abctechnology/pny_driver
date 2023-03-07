import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:pny_driver/domain/models/romaneio_model.dart';

import '../domain/datasource/romaneio_datasource.dart';
import 'delivery_details_page.dart';

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
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                DeliveryDetails(clienteRomaneio: cliente)));
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
