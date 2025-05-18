import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'AppException.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  final Dio _dio = Dio();

  factory DioClient() => _instance;

  DioClient._internal() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      validateStatus: (_) => true, // Handle manually
    );

    _dio.interceptors.add(_RequestInterceptor());

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
        ),
      );
    }
  }

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
  }) async {
    return _safeRequest(
      () => _dio.get(
        url,
        queryParameters: queryParams,
        options: Options(headers: headers),
      ),
    );
  }

  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, String>? headers,
    dynamic data,
  }) async {
    return _safeRequest(
      () => _dio.post(url, data: data, options: Options(headers: headers)),
    );
  }

  Future<Map<String, dynamic>> patch(
    String url, {
    Map<String, String>? headers,
    dynamic data,
  }) async {
    return _safeRequest(
      () => _dio.patch(url, data: data, options: Options(headers: headers)),
    );
  }

  Future<Map<String, dynamic>> delete(
    String url, {
    Map<String, String>? headers,
    dynamic data,
  }) async {
    return _safeRequest(
      () => _dio.delete(url, data: data, options: Options(headers: headers)),
    );
  }

  Future<Map<String, dynamic>> _safeRequest(
    Future<Response> Function() requestFn,
  ) async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      throw NoInternetException('No internet connection');
    }

    try {
      final response = await requestFn();
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException('Unexpected error: $e');
    }
  }

  Map<String, dynamic> _handleResponse(Response response) {
    final statusCode = response.statusCode ?? 0;

    if (statusCode >= 200 && statusCode < 300) {
      return response.data is Map<String, dynamic>
          ? response.data
          : {'data': response.data};
    }

    switch (statusCode) {
      case 400:
        throw BadRequestException(response.data.toString());
      case 401:
      case 403:
        throw UnauthorizedException(response.data.toString());
      case 404:
        throw NotFoundException('Not found: ${response.requestOptions.path}');
      case 500:
      default:
        throw ServerException('Server error: ${response.data}');
    }
  }

  AppException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return TimeoutException('Connection timed out');
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Receive timeout');
      case DioExceptionType.badResponse:
        return ServerException('Invalid server response');
      case DioExceptionType.cancel:
        return RequestCancelledException('Request was cancelled');
      case DioExceptionType.connectionError:
        return NoInternetException('Connection failed');
      default:
        return UnknownException('Something went wrong');
    }
  }
}

class _RequestInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // You can modify headers dynamically here if needed
    // Example: inject auth token if stored somewhere
    // options.headers['Authorization'] = 'Bearer your_token';
    super.onRequest(options, handler);
  }
}

Uint8List jsonToBlob(Object? json) {
  final jsonString = jsonEncode(json);
  return Uint8List.fromList(utf8.encode(jsonString));
}
