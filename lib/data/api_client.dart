import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:muit_sales_app/res/app_strings.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );

    // Har request me token apne aap lag jayega
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = GetStorage().read(AppStrings.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  Future<Response> get(String url, {Map<String, dynamic>? query}) {
    return _dio.get(url, queryParameters: query);
  }

  // data me Map ya FormData (photo / excel upload) dono chalta hai
  Future<Response> post(String url, {dynamic data}) {
    return _dio.post(url, data: data);
  }
}