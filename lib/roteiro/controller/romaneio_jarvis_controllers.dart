import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:pny_driver/interceptors/token_interceptor.dart';
import 'package:pny_driver/shared/enviroment.dart';
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
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    developer.log(entrega.toJson().toString());
    try {
      final response = await api
          .post(
        '$baseUrl/api/customized/security/PNY-RPVUPD01',
        data: entrega.toJson().toString(),
      )
          .onError((error, stackTrace) {
        developer.log(error.toString());
        developer.log(stackTrace.toString());

        throw Exception('Erro ao atualizar o romaneio');
      });

      developer.log(response.statusCode.toString());
      developer.log(response.data.toString());
      if (response.statusCode == 200) {
        developer.log(response.data.toString());

        return Right(response.data.toString());
      } else {
        developer.log(response.data.toString());

        return Left(Exception('Erro ao atualizar o romaneio'));
      }
    } on DioError catch (e, s) {
      developer.log(e.toString());
      developer.log(s.toString());
      return Left(Exception('Erro ao atualizar o romaneio'));
    }
  }
}
