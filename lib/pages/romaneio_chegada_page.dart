import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pny_driver/domain/models/romaneio_model.dart';
import 'dart:developer' as developer;

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

  _askDeliveredWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'A entrega foi efetuada?',
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

  _naoEntregueWidget() {
    // image from path to base64

    return Column(
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
          ],
        ),
      ],
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Você chegou até aqui'),
      ),
      body: Center(
          child: _statusInformado ? _statusWidget() : _askDeliveredWidget()),
    );
  }
}
