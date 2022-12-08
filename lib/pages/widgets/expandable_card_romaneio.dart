import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pny_driver/config/custom_theme.dart';
import 'package:pny_driver/domain/models/romaneio_model.dart';

class ExpandableRomaneioClienteWidget extends StatefulWidget {
  final ClienteRomaneio cliente;

  final bool deliveryOrder;
  final Function()? onTap;
  final int index;

  const ExpandableRomaneioClienteWidget(
      {super.key,
      required this.cliente,
      required this.deliveryOrder,
      required this.index,
      required this.onTap});

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
    EnderecoTemplate enderecoUm = widget.cliente.enderecos
        .where((element) => element.tipo.label == 'Endereço Entrega')
        .first;
    ClienteRomaneio cliente = widget.cliente;
    bool hasImage = cliente.entregue;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: _expanded
          ? _expandedWidget(cliente, enderecoUm, context)
          : _notExpandedWidget(hasImage, context, enderecoUm, cliente),
    );
  }

  _notExpandedWidget(bool hasImage, BuildContext context,
      EnderecoTemplate enderecoUm, ClienteRomaneio cliente) {
    var textColor = hasImage ? Colors.grey.shade700 : Colors.black;
    return Card(
        color: hasImage ? Colors.grey : Colors.white,
        elevation: 5,
        child: InkWell(
          onTap: hasImage
              ? //toast notification
              () {
                  // toast notification

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Entrega já realizada, não é possível realizar ação'),
                      duration: Duration(seconds: 3),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              : _handleExpand,
          child: ListTile(
            leading: widget.deliveryOrder
                ? Text((widget.index + 1).toString())
                : null,
            title: Text(
                '${enderecoUm.logradouro!}, ${enderecoUm.numero!} - ${enderecoUm.bairro!} - ${enderecoUm.cidade!}',
                style: TextStyle(color: textColor)),
            subtitle: Text(
              'código: ${cliente.codigo}',
              style: TextStyle(color: textColor),
            ),
            trailing: //image from base 64
                hasImage
                    ? Image.memory(
                        base64Decode(
                            //substring to remove the data:image/png;base64,
                            cliente.imagem.substring(22)),
                        fit: BoxFit.cover,
                      )
                    : null,
          ),
        ));
  }

  _expandedWidget(ClienteRomaneio cliente, EnderecoTemplate enderecoUm,
      BuildContext context) {
    return Card(
      elevation: 5,
      child: InkWell(
        onTap: () {
          _handleExpand();
        },
        child: Column(
          children: [
            ListTile(
              leading: widget.deliveryOrder
                  ? Text((widget.index + 1).toString())
                  : null,
              subtitle: Text(
                cliente.nome,
              ),
              title: Text(
                '${enderecoUm.logradouro!}, ${enderecoUm.numero!} - ${enderecoUm.bairro!} - ${enderecoUm.cidade!}',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
              trailing: IconButton(
                  onPressed: widget.onTap,
                  icon: Icon(Icons.arrow_forward_outlined)),
            ),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: cliente.pedidosDevenda.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
              ),
              itemBuilder: (BuildContext context, int index) {
                var Pedido = cliente.pedidosDevenda[index];
                return Card(
                  elevation: 5,
                  child: Column(
                    children: [
                      ListTile(
                        title: Text('pedido: ${Pedido.codigo}'),
                        subtitle: Text('itens: ${Pedido.ctn00010.length}'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
