// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:dio/dio.dart';
import 'dart:developer' as developer;
import 'package:pny_driver/domain/models/romaneio_lite_model.dart';
import 'package:pny_driver/domain/models/romaneio_model.dart';
import 'package:pny_driver/interceptors/token_interceptor.dart';
import 'package:pny_driver/shared/enviroment.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RomaneioDataSource {
  final _dio = Dio();
  RomaneioDataSource() {
    _dio.interceptors.add(TokenVerificationInterceptor(_dio));
  }
  Future<List<RomaneioLite>> getRomaneiosLite(user) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print(token);

    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MDMwMTQ0MjgsInVzZXJfbmFtZSI6IlBSRC1RSUI0OmVkc29uLm1vdG9yaXN0YSIsImF1dGhvcml0aWVzIjpbIkNPUkVfVVNFUnwwMDEwMDAwIiwiU1RVRkZfTUVOVXwwMDEwMDAwMDAwIiwiU1RVRkZfUC1QTlktWVJPTU8tMDF8MDAxMDAwMCJdLCJqdGkiOiI0Z1JGN21SMXhKV2tvZ19TSnlsdm5IX3VjUUkiLCJjbGllbnRfaWQiOiJ3ZWJAamFydmlzLjIwMjEiLCJzY29wZSI6WyJyZWFkIiwid3JpdGUiXX0.4JA35mDZ4FGFPZvR86MZd49kvTzmxzZYevKEI9reqy8',
      'X-stuff-code': 'p-pny-yromo-01'
    };
//variable with actual date in format 2022-12-08T03
    var date = '${DateTime.now().toString().substring(0, 10)}T03';

    print(date);
    final response = await _dio.post(jarvisUrl, data: {
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
      '$baseUrl/api/stuff/data/$id',
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
