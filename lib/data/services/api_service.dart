import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:paddy_scan/core/errors/exceptions.dart';
import '../models/prediction_result.dart';
import '../../core/constants/enums.dart';
import '../../core/constants/api_endpoints.dart';

class ApiService {
  Dio _dio = Dio(); // 👈 no baseUrl at construction

  // ✅ Rebuilds Dio with current IP from SharedPreferences before every call
  Future<void> _initDio() async {
    final baseUrl = await ApiEndpoints.getBaseUrl();
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: ApiEndpoints.connectionTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
    ));
  }

  Future<PredictionResult> uploadImage(
      String base64Image, AnalysisMode mode) async {
    await _initDio(); // 👈 always fresh baseUrl
    try {
      final String endpoint = mode.apiEndpoint;

      final String cleanBase64 =
          base64Image.contains(',') ? base64Image.split(',').last : base64Image;

      final Map<String, dynamic> jsonData = {
        "image": cleanBase64,
        "mode": mode.name,
      };

      final response = await _dio.post(endpoint, data: jsonData);

      // debugPrint('--- API DEBUG START ---');
      // debugPrint('Endpoint: $endpoint');
      // debugPrint('Status Code: ${response.statusCode}');
      // debugPrint('Full JSON Response: ${response.data}');
      // debugPrint('--- API DEBUG END ---');

      if (response.statusCode == 200) {
        return PredictionResult.fromJson(response.data, mode);
      } else {
        throw ServerException(
            "Server returned ${response.statusCode}", response.statusCode);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw DataFormatException("Failed to parse result", e);
    }
  }

  Future<bool> checkHealth() async {
    await _initDio(); // 👈 fresh baseUrl here too
    try {
      final response = await _dio.get(ApiEndpoints.health);
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Health Check Error: $e");
      return false;
    }
  }

  AppException _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkTimeoutException(e.message);
    }
    if (e.response?.statusCode == 404) {
      return ServerException("API Endpoint not found", 404, e.message);
    }
    if (e.type == DioExceptionType.connectionError) {
      // ✅ Shows actual current IP in error message
      return NetworkException(
          "Connection refused. Is Flask running? Check Settings → Server IP");
    }
    return ServerException(
        e.response?.data?['message'] ?? "Unexpected server error",
        e.response?.statusCode,
        e.message);
  }
}
