import 'package:dio/dio.dart';
import '../api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = 'حدث خطأ غير متوقع';
    int? statusCode = err.response?.statusCode;
    dynamic errors;

    if (err.response != null && err.response?.data != null) {
      final data = err.response?.data;
      if (data is Map<String, dynamic>) {
        message = data['message'] ?? message;
        errors = data['errors'];
      }
    } else {
      switch (err.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'انتهت مهلة الاتصال بالخادم، يرجى التحقق من الشبكة';
          break;
        case DioExceptionType.connectionError:
          message = 'تعذر الاتصال بالخادم، يرجى التحقق من تشغيل الـ API';
          break;
        default:
          message = 'فشل الاتصال بالشبكة';
      }
    }

    // Pass the mapped ApiException as the error response
    return handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: ApiException(
          message: message,
          statusCode: statusCode,
          errors: errors,
        ),
      ),
    );
  }
}
