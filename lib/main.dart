import 'package:flutter/material.dart';

import 'pages/signature_page.dart';

void main() {
  return runApp(SignaturePadApp());
}

///Renders the SignaturePad widget.
class SignaturePadApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SignaturePage(),
    );
  }
}
