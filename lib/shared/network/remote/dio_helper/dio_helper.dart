import 'package:dio/dio.dart';

abstract class DioHelper {
  static Dio? _dio;
  static Future<void> initializeDio() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://192.168.195.86:5000/"
            .trim(), // Replace with Flask server IP
        receiveDataWhenStatusError: true,
        connectTimeout: const Duration(seconds: 60), // Increased timeout
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );
  }

// ✅ **POST Request (Fix for Your Error)**
  static Future<Response> postRequest({
    required String endPoint,
    required Map<String, dynamic> data,
  }) async {
    return await _dio!.post(endPoint, data: data);
  }

  static Future<Response> getRequest({required String endPoint}) async {
    return await _dio!.get(endPoint);
  }

  static Future<Response> postFileRequest(
      {required String endPoint, required FormData formData}) async {
    return await _dio!.post(endPoint, data: formData);
  }
}
