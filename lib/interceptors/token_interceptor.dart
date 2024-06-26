import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TokenVerificationInterceptor extends Interceptor {
  Dio api;

  TokenVerificationInterceptor(this.api);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    print('REQUEST[${options.method}] => PATH: ${options.path}');

    var validation = await checkToken(options);
    if (validation.statusCode == 401) {
      print('token invalido');
      print(validation.data);
      var refresh;
      try {
        refresh = await refreshToken();
      } catch (e) {
        return super.onRequest(options, handler);
      }
      var prefs = await SharedPreferences.getInstance();
      String? token = '';
      if (refresh == true) {
        token = prefs.getString('token');
      }
      options.headers['Authorization'] = 'Bearer $token';

      return super.onRequest(options, handler);
    } else {
      return super.onRequest(options, handler);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    print(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');

    return super.onError(err, handler);
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return api.request<dynamic>(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options);
  }

  Future<Response> checkToken(RequestOptions options) async {
    var dio = Dio();

    try {
      dio.options.headers = options.headers;

      print(options.path);
      print(options.queryParameters);

      var response = await dio.request(options.path,
          data: options.data, queryParameters: options.queryParameters);

      return response;
    } catch (e) {
      return Response(statusCode: 401, requestOptions: options);
    }
  }

  Future<bool> refreshToken() async {
    var prefs = await SharedPreferences.getInstance();
    var authentication = jsonDecode(prefs.getString('authentication')!);

    var username = authentication['username'];
    var password = authentication['password'];
    print(username);
    print(password);
    var headers = {'Authorization': 'Basic YXBwQGphcnZpcy4yMDIxOldVdHQzekdO'};
    var request = http.MultipartRequest('POST',
        Uri.parse('http://qas-abctech.ddns.net:8080/jarvis/oauth/token'));
    request.fields.addAll({
      'username': 'PRD-QIB4:$username',
      'password': '$password',
      'grant_type': 'password'
    });

    request.headers.addAll(headers);
    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var resposta = jsonDecode(await response.stream.bytesToString());
        prefs.setString('token', resposta.accessToken);
        return true;
      } else {
        print(response.statusCode);
        print(response.reasonPhrase);
        return false;
      }
    } catch (e) {
      throw Exception('Verifique sua conexão');
    }
  }
}
