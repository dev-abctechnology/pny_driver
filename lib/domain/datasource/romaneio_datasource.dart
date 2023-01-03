// ignore_for_file: avoid_print

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
//variable with actual date in format 2022-12-08T03
    var date = '${DateTime.now().toString().substring(0, 10)}T03';

    print(date);
    final response = await _dio.post(
        'http://qas-abctech.ddns.net:8080/jarvis/api/stuff/data/filter',
        data: {
          "filters": [
            {
              "fieldName": "data.slt_00005.label",
              "value": "$user",
              "expression": "CONTAINS"
            }
          ],
          "sort": {"fieldName": "data.slt_00006", "type": "DESC"},
          "paginator": {"page": 0, "size": 10}
        }).onError((error, stackTrace) {
      print(error);

      throw Exception('Erro ao buscar romaneios');
    });
    final romaneios = response.data['content'] as List;
    //retone somente os 10 primeiros romaneios da lista

    var a =
        romaneios.map((romaneio) => RomaneioLite.fromJson(romaneio)).toList();
    var romaneioDeHoje =
        a.where((element) => element.deliveryDate.contains(date)).toList();
    return romaneioDeHoje;
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
        rethrow;
      }
    } else {
      throw Exception('Failed to load Romaneio');
    }
  }
}
