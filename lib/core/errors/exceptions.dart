/// Low-level Network & Infrastructure Exceptions
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'No Internet Connection'});
}

class AuthException implements Exception {
  final String message;
  const AuthException({required this.message});
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
}
