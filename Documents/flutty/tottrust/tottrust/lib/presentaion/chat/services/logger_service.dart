import 'package:logger/logger.dart';

class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );


  static void logInfo(String message) {
    _logger.i('ℹ️ INFO: $message');
  }

  static void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e('❌ ERROR: $message', error: error, stackTrace: stackTrace);
  }

  static void logWarning(String message) {
    _logger.w('⚠️ WARNING: $message');
  }

  static void logDebug(String message) {
    _logger.d('🐛 DEBUG: $message');
  }

  static void logSuccess(String message) {
    _logger.i('✅ SUCCESS: $message');
  }

  static void logRequest(String method, String url, Map<String, String>? headers, dynamic body) {
    _logger.i('''
🚀 HTTP REQUEST:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Method: $method
URL: $url
Headers: ${headers ?? 'None'}
Body: ${body ?? 'None'}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''');
  }

  static void logResponse(int statusCode, String url, dynamic body) {
    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    _logger.i('''
$emoji HTTP RESPONSE:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Status Code: $statusCode
URL: $url
Response Body: $body
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''');
  }

  static void logSocketEvent(String event, dynamic data) {
    _logger.i('''
🔌 SOCKET EVENT:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Event: $event
Data: $data
Timestamp: ${DateTime.now().toIso8601String()}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''');
  }

  static void logNavigation(String from, String to) {
    _logger.i('🧭 NAVIGATION: $from → $to');
  }

  static void logUserAction(String action, [Map<String, dynamic>? details]) {
    _logger.i('👤 USER ACTION: $action ${details != null ? '- Details: $details' : ''}');
  }
}