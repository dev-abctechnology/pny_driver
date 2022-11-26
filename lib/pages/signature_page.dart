import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:developer' as developer;
import 'dart:ui' as ui;

class SignaturePage extends StatefulWidget {
  const SignaturePage({Key? key}) : super(key: key);

  @override
  SignaturePageState createState() => SignaturePageState();
}

class SignaturePageState extends State<SignaturePage> {
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  void _handleClearButtonPressed() {
    signatureGlobalKey.currentState!.clear();
    setState(() {
      _signed = false;
    });
  }

  void _handleSaveButtonPressed(context) async {
    final data =
        await signatureGlobalKey.currentState!.toImage(pixelRatio: 3.0);

    final bytes = await data.toByteData(format: ui.ImageByteFormat.png);
    String base64 = base64Encode(bytes!.buffer.asUint8List());
    developer.log(base64);
  }

  double _minStrokeWidth = 1.0;
  double _maxStrokeWidth = 2.0;
  bool _signed = false;

  bool _handleDrawStart() {
    setState(() {
      _signed = true;
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Signature Pad'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Faça sua assinatura abaixo:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Padding(
                padding: const EdgeInsets.all(10),
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    foregroundDecoration: BoxDecoration(
                        border: Border.all(
                            color: _signed ? Colors.white : Colors.red,
                            width: 2.0)),
                    child: SfSignaturePad(
                      onDrawStart: _handleDrawStart,
                      key: signatureGlobalKey,
                      backgroundColor: Colors.white,
                      strokeColor: Colors.black,
                      minimumStrokeWidth: _minStrokeWidth,
                      maximumStrokeWidth: _maxStrokeWidth,
                    ))),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: _signed
                      ? () {
                          _handleSaveButtonPressed(context);
                        }
                      : null,
                  child: const Text('Salvar assinatura'),
                ),
                TextButton(
                  onPressed: _handleClearButtonPressed,
                  child: const Text('Limpar'),
                )
              ],
            )
          ],
        ));
  }
}
