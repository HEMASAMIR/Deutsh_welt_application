import 'package:dio/dio.dart';
import '../errors/failures.dart';

class ErrorHandler {
  static Failure handle(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    }
    return UnknownFailure('حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى');
  }

  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkFailure(
            'انتهت مهلة الاتصال، يرجى التحقق من اتصالك بالإنترنت');

      case DioExceptionType.connectionError:
        return const NetworkFailure(
            'لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة');

      case DioExceptionType.badResponse:
        return _handleStatusCode(error.response?.statusCode, error.response?.data);

      case DioExceptionType.cancel:
        return const UnknownFailure('تم إلغاء الطلب');

      default:
        return const UnknownFailure('حدث خطأ غير متوقع');
    }
  }

  static Failure _handleStatusCode(int? statusCode, dynamic data) {
    final message = _extractMessage(data);
    switch (statusCode) {
      case 400:
        return ValidationFailure(message ?? 'بيانات غير صحيحة');
      case 401:
        return UnauthorizedFailure(
            message ?? 'غير مصرح لك، يرجى تسجيل الدخول مجدداً');
      case 403:
        return const ForbiddenFailure('لا تملك صلاحية للوصول لهذه البيانات');
      case 404:
        return ServerFailure(message ?? 'البيانات المطلوبة غير موجودة');
      case 422:
        return ValidationFailure(message ?? 'بيانات غير صالحة');
      case 429:
        return const RateLimitFailure(
            'أرسلت طلبات كثيرة جداً! انتظر دقيقة ثم حاول مرة أخرى 🕐');
      case 500:
        return const ServerFailure('خطأ داخلي في الخادم، يرجى المحاولة لاحقاً');
      case 502:
        return const BunnyStreamFailure(
            'تعذر الوصول لخدمة البث. يرجى إعادة فتح الدرس أو المحاولة لاحقاً 📡');
      case 503:
        return const ServerFailure('الخادم غير متاح مؤقتاً، يرجى المحاولة لاحقاً');
      default:
        return ServerFailure(message ?? 'حدث خطأ غير متوقع');
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data == null) return null;
    String? message;
    if (data is Map) {
      message = data['message']?.toString() ??
          data['error']?.toString() ??
          data['detail']?.toString();

      // Handle field-specific validation errors (e.g., {"email": ["error"]})
      if (message == null) {
        final firstEntry = data.entries.firstOrNull;
        if (firstEntry != null && firstEntry.value is List) {
          message = (firstEntry.value as List).first.toString();
        } else if (firstEntry != null) {
          message = firstEntry.value.toString();
        }
      }
    } else {
      message = data.toString();
    }

    if (message == null) return null;

    // Translation Logic for common backend errors
    final lowerMessage = message.toLowerCase();
    if (lowerMessage.contains('no active account found') ||
        lowerMessage.contains('invalid credentials')) {
      return 'عفواً، البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (lowerMessage.contains('user with this email already exists')) {
      return 'هذا البريد الإلكتروني مسجل بالفعل';
    }
    if (lowerMessage.contains('password is too common')) {
      return 'كلمة المرور ضعيفة جداً، حاول استخدام كلمة أكثر تعقيداً';
    }
    if (lowerMessage.contains('given token not valid')) {
      return 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى';
    }

    return message;
  }
}
