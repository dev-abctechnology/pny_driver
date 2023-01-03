// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:hand_signature/signature.dart';
import 'package:pny_driver/config/custom_theme.dart';

class SignaturePage extends StatefulWidget {
  const SignaturePage({Key? key}) : super(key: key);

  @override
  SignaturePageState createState() => SignaturePageState();
}

class SignaturePageState extends State<SignaturePage> {
  void _handleClearButtonPressed() {
    // signatureGlobalKey.currentState!.clear();
    control.clear();
    setState(() {
      _signed = false;
    });
  }

  void _handleStepBackButtonPressed() {
    control.stepBack();
    print(control.isFilled);
    setState(() {
      _signed = control.isFilled;
    });
  }

  void _handleSaveButtonPressed(context) async {
    final dados = await control.toImage(
        color: Colors.black,
        height: 600,
        width: 2000,
        format: ui.ImageByteFormat.png,
        background: Colors.white);

    String base64 = base64Encode(dados!.buffer.asUint8List());
    developer.log(base64);
    // final data =
    //     await signatureGlobalKey.currentState!.toImage(pixelRatio: 3.0);

    // final bytes = await data.toByteData(format: ui.ImageByteFormat.png);
    // String base64 = base64Encode(bytes!.buffer.asUint8List());
    // developer.log(base64);
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
      ],
    );
    Navigator.of(context).pop(base64);
  }

  final control = HandSignatureControl(
    threshold: 5.0,
    smoothRatio: 0.65,
    velocityRange: 2.0,
  );

  late final HandSignature _signaturePadWidget;
  void setOrientation() {
    _vertial
        ? SystemChrome.setPreferredOrientations(
            [
              DeviceOrientation.portraitUp,
            ],
          )
        : SystemChrome.setPreferredOrientations(
            [
              DeviceOrientation.landscapeRight,
            ],
          );

    setState(() {
      _vertial = !_vertial;
    });
  }

  bool _vertial = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.landscapeRight,
      ],
    );
    _signaturePadWidget = HandSignature(
      control: control,
      color: Palette.persianasColor,
      width: 1.0,
      maxWidth: 3.0,
      type: SignatureDrawType.arc,
      onPointerDown: () {
        if (control.lines.isNotEmpty) {
          setState(() {
            _signed = true;
          });
        }
      },
      onPointerUp: () {
        if (control.lines.isNotEmpty) {
          setState(() {
            _signed = true;
          });
        }
      },
    );
  }

  bool _signed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: const Text(''),
          actions: [
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _handleClearButtonPressed,
            ),
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: _handleStepBackButtonPressed,
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => _handleSaveButtonPressed(context),
            ),
            IconButton(
              icon: const Icon(Icons.screen_rotation),
              onPressed: setOrientation,
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Assine abaixo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: AnimatedContainer(
                      alignment: Alignment.center,
                      duration: const Duration(milliseconds: 250),
                      foregroundDecoration: BoxDecoration(
                          border: Border.all(
                              color: _signed ? Colors.white : Colors.red,
                              width: 2.0)),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: _signaturePadWidget,
                      ))),
              const SizedBox(height: 10),
              // Container(
              //   color: Colors.blue,
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: <Widget>[
              //       IconButton(
              //           icon: const Icon(Icons.undo),
              //           onPressed: _handleStepBackButtonPressed),
              //       IconButton(
              //         onPressed: _handleClearButtonPressed,
              //         icon: const Icon(Icons.clear),
              //       ),
              //       IconButton(
              //           onPressed: setOrientation,
              //           icon: const Icon(Icons.screen_rotation)),
              //       TextButton(
              //         onPressed: _signed
              //             ? () {
              //                 _handleSaveButtonPressed(context);
              //               }
              //             : null,
              //         child: const Text('Salvar assinatura'),
              //       ),
              //     ],
              //   ),
              // )
            ],
          ),
        ));
  }
}
