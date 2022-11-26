import 'package:either_dart/either.dart';
import 'package:pny_driver/auth/errors/auth_exception.dart';

import 'domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<AuthException, AuthUser>> signIn(AuthSignInParams params);
  Future<void> signOut();
}

class AuthSignInParams {
  final String email;
  final String password;
  String grantType = 'password';

  AuthSignInParams({required this.email, required this.password});
}
