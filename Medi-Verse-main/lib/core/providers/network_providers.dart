import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/error_interceptor.dart';
import '../network/interceptors/logging_interceptor.dart';

/// Interceptor Providers
final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor();
});

final loggingInterceptorProvider = Provider<LoggingInterceptor>((ref) {
  return LoggingInterceptor();
});

final errorInterceptorProvider = Provider<ErrorInterceptor>((ref) {
  return ErrorInterceptor();
});

/// Dio Client Singleton Provider (Dependency Injection)
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    authInterceptor: ref.watch(authInterceptorProvider),
    loggingInterceptor: ref.watch(loggingInterceptorProvider),
    errorInterceptor: ref.watch(errorInterceptorProvider),
  );
});

/// Underlying raw Dio Provider
final dioProvider = Provider<Dio>((ref) {
  return ref.watch(dioClientProvider).dio;
});
