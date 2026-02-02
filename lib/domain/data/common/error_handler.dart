import 'package:dio/dio.dart';
import 'package:my_appp/domain/data/common/error_response.dart';

/// Common error handler for DioException
class ErrorHandler {
  /// Handle DioException and return ErrorResponse
  static ErrorResponse handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ErrorResponse(
        message: 'Request timeout',
        code: 'TIMEOUT',
      );
    } else if (e.type == DioExceptionType.connectionError) {
      return const ErrorResponse(
        message: 'No internet connection',
        code: 'CONNECTION_ERROR',
      );
    } else if (e.response != null) {
      return ErrorResponse(
        message: e.response!.statusMessage ?? 'Server error',
        code: 'SERVER_ERROR',
        statusCode: e.response!.statusCode,
      );
    } else {
      return ErrorResponse(
        message: e.message ?? 'Network error',
        code: 'NETWORK_ERROR',
      );
    }
  }

  /// Handle general exceptions
  static ErrorResponse handleException(Object e) {
    return ErrorResponse(
      message: e.toString(),
      code: 'UNEXPECTED_ERROR',
    );
  }
}
