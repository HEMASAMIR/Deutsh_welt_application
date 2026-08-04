import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../router/app_routes.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

class ApiClient {
  static const String baseUrl = 'https://py.deutschewelt.academy';

  /// Global navigator key — set this in main.dart so the interceptor
  /// can push to /login from anywhere without a BuildContext.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Dio createDio(StorageService storageService) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(storageService, dio, navigatorKey),
      TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: false,
          printRequestData: true,
          printResponseData: true,
          printResponseMessage: true,
        ),
      ),
    ]);

    return dio;
  }
}

class _AuthInterceptor extends Interceptor {
  final StorageService _storageService;
  final Dio _dio;
  final GlobalKey<NavigatorState> _navigatorKey;

  _AuthInterceptor(this._storageService, this._dio, this._navigatorKey);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = _storageService.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    final isRefreshRequest = request.path.endsWith('/api/users/login/refresh/');
    final hasRetried = request.extra['auth_retry'] == true;

    if (err.response?.statusCode == 401 && !isRefreshRequest && !hasRetried) {
      final refreshToken = _storageService.refreshToken;
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Attempt to refresh token
          final response = await Dio(BaseOptions(baseUrl: ApiClient.baseUrl)).post(
            '/api/users/login/refresh/',
            data: {'refresh': refreshToken},
          );

          final data = response.data as Map<String, dynamic>;
          final newAccess = data['access']?.toString();
          final newRefresh = data['refresh']?.toString() ?? refreshToken;
          if (newAccess == null || newAccess.isEmpty) {
            throw const FormatException('Refresh response does not include an access token.');
          }

          await _storageService.saveTokens(
            access: newAccess,
            refresh: newRefresh,
          );

          // Retry the original request with the new token
          request.headers['Authorization'] = 'Bearer $newAccess';
          request.extra['auth_retry'] = true;
          
          final retryResponse = await _dio.fetch(request);
          return handler.resolve(retryResponse);
        } catch (e) {
          // Refresh failed — clear session and redirect to login
          await _storageService.clearAll();
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            AppRoutes.login,
            (route) => false, // remove all previous routes
          );
        }
      } else {
        // No refresh token at all — redirect to login
        await _storageService.clearAll();
        _navigatorKey.currentState?.pushNamedAndRemoveUntil(
          AppRoutes.login,
          (route) => false,
        );
      }
    }
    handler.next(err);
  }
}
