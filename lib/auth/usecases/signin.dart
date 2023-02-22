// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:pny_driver/errors/auth_exception.dart';
import 'package:pny_driver/shared/enviroment.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth_repository.dart';

class AuthUseCase {
  final Dio _api;

  AuthUseCase(this._api);

  Future<Either<AuthException, String>> signIn(AuthSignInParams params) async {
    try {
      print(params.email);
      print(params.password);

      _api.options.headers = {
        'Authorization': 'Basic YXBwQGphcnZpcy4yMDIxOldVdHQzekdO',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      final response = await _api.post(
        '$baseUrl/oauth/token',
        data: {
          'username': params.email,
          'password': params.password,
          'grant_type': 'password',
        },
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        var token = response.data['access_token'];
        // store in sharedPreferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString(
            'authentication',
            jsonEncode(
                {'username': params.email, 'password': params.password}));
        prefs.setString('token', token);
        await getUserLogged();
        return Right(token);
      } else {
        return Left(AuthException(message: 'Invalid credentials'));
      }
    } on AuthException catch (e, s) {
      print(e);
      print(s);
      return Left(e);
    } catch (e, s) {
      print(e);
      print(s);
      return Left(AuthException(message: 'Something went wrong'));
    }
  }

  Future<void> getUserLogged() async {
    Dio dio = Dio();
    var token = await SharedPreferences.getInstance()
        .then((value) => value.getString('token'));
    var authentication = await SharedPreferences.getInstance()
        .then((value) => value.getString('authentication'));

    String username = jsonDecode(authentication!)['username'];
    //remove PRD-QIB4: from username
    username = username.substring(9);

    dio.options.headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      var response = await dio.post('$baseUrl/api/core/users/filter', data: {
        "filters": [
          {"fieldName": "username", "value": username, "expression": "CONTAINS"}
        ]
      });
      print(response.data);
      if (response.statusCode == 200) {
        var resposta = await response.data;
        print(resposta);
        var name = resposta[0]['name'];
        var profile = resposta[0]['profile'];
        print(profile);
        if (profile == 'Motorista') {
          print('tem acesso');
        } else {
          print('não tem acesso');
          developer.log('Esse usuário NÃO DEVE TER ACESSO AO SISTEMA',
              name: 'ATENÇÃO',
              error: 'Esse usuário NÃO DEVE TER ACESSO AO SISTEMA');
          developer.log('Esse usuário NÃO DEVE TER ACESSO AO SISTEMA',
              name: 'ATENÇÃO',
              error: 'Esse usuário NÃO DEVE TER ACESSO AO SISTEMA');
          developer.log('Esse usuário NÃO DEVE TER ACESSO AO SISTEMA',
              name: 'ATENÇÃO',
              error: 'Esse usuário NÃO DEVE TER ACESSO AO SISTEMA');
          developer.log('Esse usuário NÃO DEVE TER ACESSO AO SISTEMA',
              name: 'ATENÇÃO',
              error: 'Esse usuário NÃO DEVE TER ACESSO AO SISTEMA');
        }

        var prefs = await SharedPreferences.getInstance();
        prefs.setString('name', name);
      } else {
        print(response.statusCode);
        throw Exception('Erro ao buscar usuário');
      }
    } on DioError catch (e, s) {
      print(e);
      print(s);
    } catch (e, s) {
      print(e);
      print(s);
    }
  }
}
