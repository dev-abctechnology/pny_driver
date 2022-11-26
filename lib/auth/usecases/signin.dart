import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:pny_driver/auth/errors/auth_exception.dart';

import '../../interceptors/token_interceptor.dart';
import '../auth_repository.dart';
import '../domain/entities/user.dart';

class AuthUseCase implements AuthRepository {
  final Dio _api;

  AuthUseCase(this._api);

  @override
  Future<Either<AuthException, AuthUser>> signIn(
      AuthSignInParams params) async {
    // try make a request to the api
    // if success return AuthUser
    // if error return AuthException

    _api.interceptors.add(TokenVerificationInterceptor(_api));

    var response =
        await _api.post('https://api.pny.com.br/api/v1/auth/login', data: {
      'email': params.email,
      'password': params.password,
    });

    if (response.statusCode == 200) {
      var user = AuthUser.fromJson(response.data['user']);
      return Right(user);
    } else {
      return Left(AuthException(message: response.data['message']));
    }
  }

  @override
  Future<void> signOut() async {}
}
