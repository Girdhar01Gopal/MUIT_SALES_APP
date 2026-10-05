import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import 'package:muit_sales_app/data/api_client.dart';
import 'package:muit_sales_app/data/api_url.dart';

class UploadRepo {
  // Jab tak backend ready nahi, true rakho (sirf UI test ke liye).
  // API ready hone par false kar dena.
  static const bool useDummy = true;

  final ApiClient _api = Get.find<ApiClient>();

  Future<bool> uploadVisitPhoto({
    required File photo,
    required double lat,
    required double lng,
    required String address,
  }) async {
    if (useDummy) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    final form = FormData.fromMap({
      'photo': await MultipartFile.fromFile(
        photo.path,
        filename: photo.path.split('/').last,
      ),
      'latitude': lat,
      'longitude': lng,
      'address': address,
    });

    final res = await _api.post(ApiUrl.uploadPhoto, data: form);
    return res.statusCode == 200 || res.statusCode == 201;
  }

  Future<bool> uploadExcel(PlatformFile file) async {
    if (useDummy) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path!, filename: file.name),
    });

    final res = await _api.post(ApiUrl.uploadExcel, data: form);
    return res.statusCode == 200 || res.statusCode == 201;
  }
}