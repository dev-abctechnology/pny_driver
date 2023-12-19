// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:pny_driver/shared/enviroment.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../interceptors/token_interceptor.dart';
import '../models/romaneio_lite_model.dart';

class HistoricoRepository with ChangeNotifier {
  int _index = 0;
  // ignore: prefer_final_fields
  var _historico = <RomaneioLite>[];

  List<RomaneioLite> get historico => _historico;

  getRomaneiosHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    String username = prefs.getString('name') ?? '';
    final dio = Dio();
    dio.interceptors.add(TokenVerificationInterceptor(dio));

    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'X-stuff-code': 'p-pny-yromo-01'
    };

    var payload = {
      "filters": [
        {
          "fieldName": "data.slt_00005.label",
          "value": username,
          "expression": "CONTAINS"
        }
      ],
      "sort": {"fieldName": "data.slt_00006", "type": "DESC"},
      "paginator": {"page": _index, "size": 15}
    };

    final response =
        await dio.post(jarvisUrl, data: payload).onError((error, stackTrace) {
      throw Exception('Erro ao buscar o historico');
    });
    final content = response.data['content'] as List;

    var resposta =
        content.map((romaneio) => RomaneioLite.fromJson(romaneio)).toList();

    var date = '${DateTime.now().toString().substring(0, 10)}T03';
    print(date);
    print(resposta[0].deliveryDate);

    resposta.removeWhere((element) => element.deliveryDate.contains(date));

    _historico.addAll(resposta);
    _index++;
    notifyListeners();
  }
}
