import 'package:dio/dio.dart';
import '../../errors/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        throw const NetworkException(message: 'Connection timed out or network unavailable.');

      case DioExceptionType.badResponse:
        final code = err.response?.statusCode;
        final msg = err.response?.data?['message'] ?? 'Server error occurred.';
        if (code == 401) {
          throw AuthException(message: msg);
        }
        throw ServerException(message: msg, statusCode: code);

      default:
        throw ServerException(message: err.message ?? 'Unexpected error occurred.');
    }
  }
}
