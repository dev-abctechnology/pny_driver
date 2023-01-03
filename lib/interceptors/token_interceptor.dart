// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:shared_preferences/shared_preferences.dart';

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
      bool refresh;
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

    var dio = Dio();

    dio.options.headers = {
      'Authorization': 'Basic YXBwQGphcnZpcy4yMDIxOldVdHQzekdO',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final response = await dio.post(
      'http://qas-abctech.ddns.net:8080/jarvis/oauth/token',
      data: {
        'username': username,
        'password': password,
        'grant_type': 'password',
      },
    );

    if (response.statusCode == 200) {
      var token = response.data['access_token'];
      prefs.setString('token', token);
      return true;
    } else {
      return false;
    }
  }
}
