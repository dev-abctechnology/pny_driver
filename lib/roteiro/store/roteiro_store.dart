import 'dart:convert';

import 'package:pny_driver/domain/models/romaneio_general_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RomaneioGeneralController {
  Future<void> _saveTravel(String json) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('travel', json);
  }

  Future _getTravel() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      return prefs.getString('travel');
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveTravel(RomaneioGeneral romaneioGeneral) async {
    try {
      final String json = jsonEncode(romaneioGeneral.toMap());
      await _saveTravel(json);
      return true;
    } catch (e, s) {
      print(e);
      print(s);
      return false;
    }
  }

  Future<RomaneioGeneral> getTravel() async {
    try {
      final String json = await _getTravel();
      return RomaneioGeneral.fromMap(jsonDecode(json) as Map<String, dynamic>);
    } catch (e, s) {
      print(e);
      print(s);
      rethrow;
    }
  }

  Future<bool> deleteTravel() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('travel');
      return true;
    } catch (e, s) {
      print(e);
      print(s);
      return false;
    }
  }

  Future<bool> hasTravel() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('travel');
  }
}
