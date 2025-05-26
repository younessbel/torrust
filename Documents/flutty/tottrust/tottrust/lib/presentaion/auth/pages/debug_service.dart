import 'dart:developer' as developer;

class DebugService {
  static void logError(String tag, dynamic error, [StackTrace? stackTrace]) {
    developer.log(
      '❌ ERROR: $error',
      name: tag,
      error: error,
      stackTrace: stackTrace,
    );
    
    // You can also implement additional error reporting here
    // such as sending to a remote logging service
  }
  
  static void logInfo(String tag, String message) {
    developer.log(
      '📘 INFO: $message',
      name: tag,
    );
  }
  
  static void logApiResponse(String endpoint, dynamic response, int statusCode) {
    developer.log(
      '🌐 API RESPONSE: $endpoint - Status: $statusCode',
      name: 'API',
      error: statusCode >= 400 ? 'Error response' : null,
    );
    developer.log(
      '📦 RESPONSE BODY: $response',
      name: 'API',
    );
  }
  
  static void logApiRequest(String endpoint, dynamic body) {
    developer.log(
      '🌐 API REQUEST: $endpoint',
      name: 'API',
    );
    developer.log(
      '📦 REQUEST BODY: $body',
      name: 'API',
    );
  }
}
