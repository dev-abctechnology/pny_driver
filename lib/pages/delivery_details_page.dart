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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nome: ${widget.clienteRomaneio.nome}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left),
            const SizedBox(
              height: 10,
            ),
            Text('CNPJ: ${widget.clienteRomaneio.cnpj}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left),
            const SizedBox(
              //create a space between the text and the next widget
              height: 10,
            ),
            Text(
                'Endereço: ${widget.clienteRomaneio.enderecos[0].logradouro!}, ${widget.clienteRomaneio.enderecos[0].numero!} - ${widget.clienteRomaneio.enderecos[0].bairro!} - ${widget.clienteRomaneio.enderecos[0].cidade!}',
                textAlign: TextAlign.left,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(
              //create a space between the text and the next widget
              height: 10,
            ),
            ListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                for (var pedido in pedidos)
                  ExpansionTile(
                    title: Row(
                      children: [
//image asset 'assets/images/box.png' in left side of the title
                        Image.asset(
                          'assets/images/box.png',
                          width: 30,
                        ),
                        const SizedBox(width: 10),

                        Text('Pedido: ${pedido.codigo}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    subtitle: Text(pedido.referencia != null
                        ? 'Ref: ${pedido.referencia}'
                        : ''),
                    children: [
                      ListTile(
                        title: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: pedido.ctn00010.length,
                          itemBuilder: (context, index) {
                            var item = pedido.ctn00010[index];
                            return Card(
                              child: ExpansionTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
//asset image 'assets/images/persiana.png' in left side of the title
                                        Image.asset(
                                          'assets/images/persiana.png',
                                          width: 30,
                                        ),
                                        const SizedBox(width: 10),

                                        Expanded(
                                          child: Text(
                                            item.descricao.toLowerCase(),
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text('Código: ${item.codigoProduto}'),
                                    Text('itm: ${item.itm}'),
                                  ],
                                ),
                                children: [
                                  if (item.modelo != null &&
                                      item.modelo!.isNotEmpty)
                                    Text('Modelo: ${item.modelo!}'),
                                  Text('Quantidade: ${item.quantidade}x'),
                                  Text('altura: ${item.altura}m'),
                                  Text('largura: ${item.largura}m'),
                                  Text(
                                      'm² cobrado: ${item.metroQuadradoCobrado}m²'),
                                  if (item.observacao1 != null &&
                                      item.observacao1!.isNotEmpty)
                                    ListTile(
                                      title: const Text('Observação:'),
                                      subtitle:
                                          Text(item.observacao1!.toLowerCase()),
                                    ),
                                  if (item.observacaoAcionamentos != null &&
                                      item.observacaoAcionamentos!.isNotEmpty)
                                    ListTile(
                                      title: const Text('Acionamentos:'),
                                      subtitle: Text(item
                                          .observacaoAcionamentos!
                                          .toLowerCase()),
                                    ),
                                  if (item.observacaoOpcionais != null &&
                                      item.observacaoOpcionais!.isNotEmpty)
                                    ListTile(
                                      title: const Text('Opcionais:'),
                                      subtitle: Text(item.observacaoOpcionais!
                                          .toLowerCase()
                                          .split('/')
                                          .join('\n')
                                          .toLowerCase()),
                                    ),
                                  if (item.fotoBase64 != null &&
                                      item.fotoBase64!.isNotEmpty)
                                    Image.memory(
                                      base64Decode(item.fotoBase64!),
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
