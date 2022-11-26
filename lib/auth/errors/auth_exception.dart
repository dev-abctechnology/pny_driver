class AuthException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  AuthException({required this.message, this.stackTrace});

  @override
  String toString() {
    return 'AuthException{message: $message, stackTrace: $stackTrace}';
  }
}
