class ApiError implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;

  ApiError({
    required this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() {
    return 'ApiError(statusCode: $statusCode, message: $message, data: $data)';
  }

  // Thêm getter để dễ dàng check
  bool get isNotFound => statusCode == 404;
  bool get isSuccessful => statusCode >= 200 && statusCode < 300;
  bool get isNoContent => statusCode == 204;
}