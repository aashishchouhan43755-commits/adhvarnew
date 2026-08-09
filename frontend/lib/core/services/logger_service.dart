import 'dart:developer' as developer;

class LoggerService {
  LoggerService._();

  static const String _tag = 'ADHVAR';

  static void debug(String message) {
    developer.log(message, name: _tag, level: 500);
  }

  static void info(String message) {
    developer.log(message, name: _tag, level: 800);
  }

  static void warning(String message) {
    developer.log(message, name: _tag, level: 900);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: _tag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void apiRequest({
    required String method,
    required String url,
    Map<String, dynamic>? body,
  }) {
    developer.log('''
================ API REQUEST ================
Method : $method
URL    : $url
Body   : ${body ?? {}}
============================================
''', name: _tag);
  }

  static void apiResponse({
    required String url,
    required int statusCode,
    dynamic response,
  }) {
    developer.log('''
================ API RESPONSE ===============
URL         : $url
Status Code : $statusCode
Response    : $response
============================================
''', name: _tag);
  }

  static void exception(Object exception, StackTrace stackTrace) {
    developer.log(
      '''
=============== EXCEPTION ===================
Exception : $exception

StackTrace:
$stackTrace
============================================
''',
      name: _tag,
      error: exception,
      stackTrace: stackTrace,
    );
  }
}
