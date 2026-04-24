import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

class ApiService {
  static final ApiService _i = ApiService._();
  factory ApiService() => _i;
  ApiService._();

  late final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 5), // AI processing takes time
    headers: {'Content-Type': 'application/json'},
  ));

  // Get fresh Firebase token — attach to every request
  Future<String> _token() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Not logged in');
    return await user.getIdToken() ?? '';
  }

  Future<Options> _opts() async => Options(
    headers: {'Authorization': 'Bearer ${await _token()}'},
  );

  // ── Auth ────────────────────────────────────────────────
  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get(AppConstants.me, options: await _opts());
    return res.data;
  }

  // ── Watermark Remove ────────────────────────────────────
  Future<Map<String, dynamic>> removeWatermark(File image, {File? mask}) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path, filename: 'image.jpg'),
      if (mask != null) 'mask': await MultipartFile.fromFile(mask.path, filename: 'mask.png'),
    });
    final res = await _dio.post(AppConstants.watermark,
        data: form, options: await _opts());
    return res.data;
  }

  // ── BG Remove ───────────────────────────────────────────
  Future<Map<String, dynamic>> removeBackground(File image, {String? bgColor}) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path, filename: 'image.jpg'),
      if (bgColor != null) 'bg_color': bgColor,
    });
    final res = await _dio.post(AppConstants.bgPhoto,
        data: form, options: await _opts());
    return res.data;
  }

  // ── Enhance ─────────────────────────────────────────────
  Future<Map<String, dynamic>> enhanceImage(File image,
      {int scale = 2, String enhanceType = 'upscale'}) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path, filename: 'image.jpg'),
      'scale': scale.toString(),
      'enhance_type': enhanceType,
    });
    final res = await _dio.post(AppConstants.enhanceImage,
        data: form, options: await _opts());
    return res.data;
  }

  // ── Video ───────────────────────────────────────────────
  Future<Map<String, dynamic>> processVideo(File video,
      {required String tool, Map<String, dynamic>? params}) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(video.path, filename: 'video.mp4'),
      'tool': tool,
      'params': (params ?? {}).toString(),
    });
    final res = await _dio.post(AppConstants.videoProcess,
        data: form, options: await _opts());
    return res.data;
  }

  // ── Job polling ─────────────────────────────────────────
  Future<Map<String, dynamic>> getJobStatus(String jobId) async {
    final res = await _dio.get(AppConstants.jobStatus(jobId), options: await _opts());
    return res.data;
  }

  Future<List<dynamic>> getHistory() async {
    final res = await _dio.get(AppConstants.jobHistory, options: await _opts());
    return res.data['history'] ?? [];
  }

  // ── Payments ────────────────────────────────────────────
  Future<Map<String, dynamic>> createOrder(String plan) async {
    final res = await _dio.post(AppConstants.createOrder,
        data: {'plan': plan}, options: await _opts());
    return res.data;
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
    required String plan,
  }) async {
    final res = await _dio.post(AppConstants.verifyPay,
        data: {
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature,
          'plan': plan,
        },
        options: await _opts());
    return res.data;
  }
}
