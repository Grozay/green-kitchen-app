class ApiError {
  final String message;
  final int? statusCode;
  final String? errorCode;

  ApiError({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] ?? 'Unknown error occurred',
      statusCode: json['statusCode'],
      errorCode: json['errorCode'],
    );
  }
}