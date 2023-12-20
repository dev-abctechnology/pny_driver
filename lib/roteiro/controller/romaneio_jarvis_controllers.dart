import 'dart:convert';
import 'dart:developer' as developer;
import 'package:date_format/date_format.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:intl/intl.dart';
import 'package:pny_driver/interceptors/token_interceptor.dart';
import 'package:pny_driver/shared/enviroment.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/romaneio_custom_api_model.dart';

class RomaneioJarvisController {
  Dio api;

  RomaneioJarvisController(this.api) {
    api.interceptors.add(TokenVerificationInterceptor(Dio()));
  }
  Future<Either<Exception, String>> updateRomaneio(
      RomaneioEntregue entrega) async {
    var prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('token');

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

        throw Exception('Erro ao atualizar o romaneio: $error');
      });

      developer.log(response.statusCode.toString());
      developer.log(response.data.toString());
      if (response.statusCode == 200) {
        developer.log(response.data.toString());

        return Right(response.data.toString());
      } else {
        developer.log(response.data.toString());

        return Left(
            Exception('Erro ao atualizar o romaneio: ${response.data}'));
      }
    } on DioError catch (e, s) {
      developer.log(e.toString());
      developer.log(s.toString());
      return Left(Exception('Erro ao atualizar o romaneio $e'));
    }
  }

  Future<bool> executePipeline(List<String> pedidos) async {
    try {
      final token = await generateGHSToken();
      await executeRequestsUpdatePedidoGHS(pedidos, token);
      print('Pipeline concluído com sucesso');
      return true;
    } catch (e) {
      print('Erro no pipeline: $e');
      return false;
    }
  }

  Future<String> generateGHSToken() async {
    var headers = {'Authorization': 'Basic R0hTQVBJOmdoc0BhcGkyMDIwIyQl'};
    var dio = Dio();
    var response = await dio.request(
      'http://grupotradicao.sytes.net:8082/api/login',
      options: Options(
        method: 'GET',
        headers: headers,
      ),
    );

    if (response.statusCode == 200) {
      final token = response.data['token'];

      return token;
    } else {
      print(response.statusMessage);
      throw Exception('Erro ao gerar token');
    }
  }

  Future<void> executeRequestsUpdatePedidoGHS(
      List<String> pedidos, String token) async {
    List<Future<bool>> futures = [];

    for (String pedido in pedidos) {
      futures.add(updatePedidoGHS(pedido, token));
    }

    final requests = await Future.wait(futures);

    List<Map<String, dynamic>> jsonStatus = [];

    requests.asMap().forEach((index, request) {
      jsonStatus.add({
        "pedido": pedidos[index],
        "status": request,
      });
    });

    print(jsonStatus);
  }

  Future<bool> updatePedidoGHS(String pedido, String token) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final date = DateTime.now();
    String dateFormatted =
        formatDate(date, [dd, '/', mm, '/', yyyy, ' ', HH, ':', nn]);

    var data = json.encode({
      "indicador": "I",
      "codigo_pv": int.parse(pedido),
      "codigo_empresa": "4",
      "status": "ENTREGUE",
      "data_entrega_efetuada": dateFormatted
    });

    var dio = Dio();

    print(data);
    try {
      var response = await dio.post(
        'http://grupotradicao.sytes.net:8082/api/atualizaentrega',
        options: Options(
          headers: headers,
        ),
        data: data,
      );

      if (response.statusCode == 201) {
        print('Pedido $pedido atualizado com sucesso');
        print(json.encode(response.data));
        return true;
      } else {
        print(
            'Erro ao atualizar o pedido $pedido: ${response.statusCode} - ${response.data} - ${response.statusMessage}');
        return false;
      }
    } catch (e) {
      print('Erro ao atualizar o pedido $pedido: $e');
      return false;
    }
  }
}
