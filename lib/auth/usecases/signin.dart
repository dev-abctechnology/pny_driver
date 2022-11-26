import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:pny_driver/auth/errors/auth_exception.dart';

import '../../interceptors/token_interceptor.dart';
import '../auth_repository.dart';
import '../domain/entities/user.dart';

class AuthUseCase {
  final Dio _api;

  AuthUseCase(this._api);

  Future<Either<AuthException, String>> signIn(AuthSignInParams params) async {
    try {
      print(params.email);
      print(params.password);

      _api.options.headers = {
        'Authorization': 'Basic YXBwQGphcnZpcy4yMDIxOldVdHQzekdO',
      };

      final response = await _api.post(
        'http://qas-abctech.ddns.net:8080/jarvis/oauth/token',
        data: {
          'username': params.email,
          'password': params.password,
          'grant_type': 'password',
        },
      );

      print(response.statusCode);
      if (response.statusCode == 200) {
        var token = response.data['access_token'];
        return Right(token);
      } else {
        return Left(AuthException(message: 'Invalid credentials'));
      }
    } catch (e, s) {
      print(e);
      print(s);
      return Left(AuthException(message: 'Error signing in'));
    }
  }
}
