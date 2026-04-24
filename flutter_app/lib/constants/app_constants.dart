// ✅ NO SECRETS HERE — only public config
class AppConstants {
  // 👇 Render deploy ke baad yahan apna URL daalo
  static const String baseUrl = 'https://clearcut-api.onrender.com/api/v1';

  // API endpoints
  static const String me            = '$baseUrl/auth/me';
  static const String deleteAccount = '$baseUrl/auth/account';
  static const String watermark     = '$baseUrl/watermark/remove';
  static const String bgPhoto       = '$baseUrl/bgremove/photo';
  static const String enhanceImage  = '$baseUrl/enhance/image';
  static const String videoProcess  = '$baseUrl/video/process';
  static const String createOrder   = '$baseUrl/payments/create-order';
  static const String verifyPay     = '$baseUrl/payments/verify';
  static const String jobHistory    = '$baseUrl/jobs/history/list';
  static String jobStatus(String id) => '$baseUrl/jobs/$id';

  // App info
  static const String appName    = 'ClearCut';
  static const String appVersion = '1.0.0';

  // Free tier limit
  static const int freeDailyLimit = 5;
}

class AppColors {
  static const bg      = 0xFF04040F;
  static const surface = 0xFF0E0E24;
  static const cyan    = 0xFF00F5D4;
  static const violet  = 0xFF9B5DE5;
  static const pink    = 0xFFF72585;
  static const gold    = 0xFFFFD60A;
  static const white   = 0xFFE8E8F0;
  static const muted   = 0xFF5A5A7A;
}
