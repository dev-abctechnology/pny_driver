import 'dart:convert';

import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'package:pny_driver/domain/models/romaneio_lite_model.dart';
import 'package:pny_driver/domain/models/romaneio_model.dart';
import 'package:pny_driver/interceptors/token_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RomaneioDataSource {
  final _dio = Dio();

  Future<List<RomaneioLite>> getRomaneiosLite(user) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    _dio.interceptors.add(TokenVerificationInterceptor(_dio));

    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authentication': 'Bearer $token',
      'X-stuff-code': 'p-pny-yromo-01'
    };

    final response = await _dio.post(
        'http://qas-abctech.ddns.net:8080/jarvis/api/stuff/data/filter',
        data: {
          "filters": [
            {
              "fieldName": "data.slt_00001.label",
              "value": "PROPRIO",
              "expression": "CONTAINS"
            }
          ],
          "sort": {"fieldName": "id", "type": "ASC"}
        });
    final romaneios = response.data as List;
    return romaneios
        .map((romaneio) => RomaneioLite.fromJson(romaneio))
        .toList();
  }

  Future<Romaneio> getRomaneioById(id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print(token);

    _dio.interceptors.add(TokenVerificationInterceptor(Dio()));

    _dio.options.headers = {
      'Content-Type': 'application/json, text/plain, */*',
      'Accept': 'application/json, text/plain, */*',
      'Authorization': 'Bearer $token',
      'X-stuff-code': 'p-pny-yromo-01'
    };

    final response = await _dio
        .get(
      'http://qas-abctech.ddns.net:8080/jarvis/api/stuff/data/$id',
    )
        .then((value) {
      return value;
    });

    print(response.statusCode);
    if (response.statusCode == 202) {
      try {
        developer.log(jsonEncode(response.data));
        final romaneio = Romaneio.fromJson(response.data);
        return romaneio;
      } catch (e, s) {
        print(e);
        print(s);
        throw e;
      }
    } else {
      throw Exception('Failed to load Romaneio');
    }
  }
}
