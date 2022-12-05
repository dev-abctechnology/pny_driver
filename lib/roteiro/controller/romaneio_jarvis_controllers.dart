import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:pny_driver/interceptors/token_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/romaneio_custom_api_model.dart';

class RomaneioJarvisController {
  Dio api;

  RomaneioJarvisController(this.api);

  Future<Either<Exception, String>> updateRomaneio(
      RomaneioEntregue entrega) async {
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

    api.interceptors.add(TokenVerificationInterceptor(Dio()));

    api.options.headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $token'
    };

    developer.log(entrega.toJson().toString());

    final response = await api.post(
      'http://qas-abctech.ddns.net:8080/jarvis/api/customized/secaurity/PNY-RPVUPD01',
      data: entrega.toJson().toString(),
    );
    if (response.statusCode == 200) {
      return Right(response.data);
    } else {
      return Left(Exception('Erro ao atualizar o romaneio'));
    }
  }
}
