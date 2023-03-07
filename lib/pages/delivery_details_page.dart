import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pny_driver/domain/models/romaneio_model.dart';

class DeliveryDetails extends StatefulWidget {
  final ClienteRomaneio clienteRomaneio;

  const DeliveryDetails({super.key, required this.clienteRomaneio});

  @override
  State<DeliveryDetails> createState() => _DeliveryDetailsState();
}

class _DeliveryDetailsState extends State<DeliveryDetails> {
  @override
  Widget build(BuildContext context) {
//create variables to store the data from every part of the cliente
    final pedidos = widget.clienteRomaneio.pedidosDevenda;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da entrega'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Text('Nome: ${widget.clienteRomaneio.nome}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('CNPJ: ${widget.clienteRomaneio.cnpj}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                for (var pedido in pedidos)
                  Card(
                    child: ListTile(
                        title: Text('Pedido: ${pedido.codigo}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: ListView(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            for (var item in pedido.ctn00010)
                              Card(
                                child: ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.descricao.toLowerCase(),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text('Código: ${item.codigoProduto}'),
                                      Text('itm: ${item.itm}'),
                                      item.modelo != null &&
                                              item.modelo!.isNotEmpty
                                          ? Text('Modelo: ${item.modelo!}')
                                          : Container(),
                                      Text('Quantidade: ${item.quantidade}x'),
                                      Text('altura: ${item.altura}m'),
                                      Text('largura: ${item.largura}m'),
                                      Text(
                                          'm² cobrado: ${item.metroQuadradoCobrado}m²'),
                                      item.observacao1 != null &&
                                              item.observacao1!.isNotEmpty
                                          ? ListTile(
                                              title: const Text('Observação:'),
                                              subtitle: Text(item.observacao1!
                                                  .toLowerCase()),
                                            )
                                          : Container(),
                                      item.observacaoAcionamentos != null &&
                                              item.observacaoAcionamentos!
                                                  .isNotEmpty
                                          ? ListTile(
                                              title:
                                                  const Text('Acionamentos:'),
                                              subtitle: Text(item
                                                  .observacaoAcionamentos!
                                                  .toLowerCase()),
                                            )
                                          : Container(),
                                      item.observacaoOpcionais != null &&
                                              item.observacaoOpcionais!
                                                  .isNotEmpty
                                          ? ListTile(
                                              title: const Text('Opcionais:'),
                                              subtitle: Text(item
                                                  .observacaoOpcionais!
                                                  .toLowerCase()),
                                            )
                                          : Container(),
                                      item.fotoBase64 != null &&
                                              item.fotoBase64!.isNotEmpty
                                          ? Image.memory(
                                              base64Decode(item.fotoBase64!),
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                              )
                          ],
                        )),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
