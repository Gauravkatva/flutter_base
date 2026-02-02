import 'package:my_appp/domain/data/common/error_response.dart';

/// Generic API response wrapper
class Response<T> {
  const Response._({
    required this.isSuccess,
    this.data,
    this.error,
  });

  /// Create a success response
  factory Response.success(T data) {
    return Response._(
      isSuccess: true,
      data: data,
    );
  }

  /// Create an error response
  factory Response.error(ErrorResponse error) {
    return Response._(
      isSuccess: false,
      error: error,
    );
  }

  final T? data;
  final ErrorResponse? error;
  final bool isSuccess;
}
