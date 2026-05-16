import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/constants/enums.dart';
import '../../core/errors/exceptions.dart';
import '../models/prediction_result.dart';

class HttpService {
  final http.Client _client = http.Client();

  Future<bool> checkHealth() async {
    try {
      final url =
          await ApiEndpoints.getFullUrl(ApiEndpoints.health); // 👈 await
      final response = await _client
          .get(Uri.parse(url))
          .timeout(ApiEndpoints.connectionTimeout);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getModelInfo() async {
    try {
      final url =
          await ApiEndpoints.getFullUrl(ApiEndpoints.modelInfo); // 👈 await
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw ServerException('Failed to get model info: ${response.statusCode}',
          response.statusCode);
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      throw ServerException('Error: $e');
    }
  }

  Future<PredictionResult> classifyImage(File imageFile) async {
    return _postMultipart(
        imageFile, ApiEndpoints.classify, AnalysisMode.classify);
  }

  Future<PredictionResult> detectImage(File imageFile) async {
    return _postMultipart(imageFile, ApiEndpoints.detect, AnalysisMode.detect);
  }

  Future<PredictionResult> diagnoseImage(File imageFile) async {
    return _postMultipart(
        imageFile, ApiEndpoints.diagnose, AnalysisMode.diagnose);
  }

  Future<PredictionResult> classifyImageWeb(String base64Image) async {
    try {
      final url =
          await ApiEndpoints.getFullUrl(ApiEndpoints.classify); // 👈 await
      final response = await _client
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'image': base64Image}),
          )
          .timeout(ApiEndpoints.receiveTimeout);

      if (response.statusCode == 200) {
        return PredictionResult.fromJson(
            json.decode(response.body), AnalysisMode.classify);
      }
      throw ServerException(
          'Classification failed: ${response.statusCode}', response.statusCode);
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      throw ServerException('Error: $e');
    }
  }

  Future<PredictionResult> _postMultipart(
    File imageFile,
    String endpoint,
    AnalysisMode mode,
  ) async {
    try {
      final url = await ApiEndpoints.getFullUrl(endpoint); // 👈 await
      var request = http.MultipartRequest('POST', Uri.parse(url));

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return PredictionResult.fromJson(json.decode(response.body), mode);
      }
      throw ServerException(
          'Request to $endpoint failed: ${response.statusCode}',
          response.statusCode);
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      throw ServerException('Error: $e');
    }
  }

  // ✅ Now async too
  Future<String> getPreviewUrl(String previewPath) async {
    return ApiEndpoints.getFullUrl('${ApiEndpoints.preview}/$previewPath');
  }

  void dispose() {
    _client.close();
  }
}
