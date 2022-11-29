import 'package:flutter/cupertino.dart';

class TokenStore extends ChangeNotifier {
  String? _token;

  TokenStore({String? token}) : _token = token;

  String? get token => _token;

  setToken(String token) {
    _token = token;
    notifyListeners();
  }

  init() {
    _token = null;
  }
}
