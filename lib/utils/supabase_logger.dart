import 'dart:convert';
import 'dart:developer' as developer;

/// A class for logging Supabase operations
class SupabaseLogger {
  // Singleton instance
  static final SupabaseLogger _instance = SupabaseLogger._internal();
  
  factory SupabaseLogger() {
    return _instance;
  }
  
  SupabaseLogger._internal();
  
  // Log levels
  static const int VERBOSE = 0;
  static const int DEBUG = 1;
  static const int INFO = 2;
  static const int WARNING = 3;
  static const int ERROR = 4;
  
  // Current log level - change this to adjust logging verbosity
  int _currentLogLevel = DEBUG;
  
  /// Set the current log level
  void setLogLevel(int level) {
    _currentLogLevel = level;
  }
  
  /// Log a message at verbose level (highly detailed information)
  void v(String tag, String message, [Object? data]) {
    _log(VERBOSE, tag, message, data);
  }
  
  /// Log a message at debug level (useful for development/debugging)
  void d(String tag, String message, [Object? data]) {
    _log(DEBUG, tag, message, data);
  }
  
  /// Log a message at info level (general information about app operation)
  void i(String tag, String message, [Object? data]) {
    _log(INFO, tag, message, data);
  }
  
  /// Log a message at warning level (potential issues that aren't errors)
  void w(String tag, String message, [Object? data]) {
    _log(WARNING, tag, message, data);
  }
  
  /// Log a message at error level (errors and exceptions)
  void e(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    _log(ERROR, tag, message, error, stackTrace);
  }
  
  /// Log a Supabase request
  void logRequest(String operation, String endpoint, Object? data) {
    final Map<String, dynamic> logData = {
      'endpoint': endpoint,
      'data': data,
    };
    i('SUPABASE_REQUEST', '[$operation] Request', logData);
  }
  
  /// Log a Supabase response
  void logResponse(String operation, String endpoint, Object? response, int? statusCode) {
    final Map<String, dynamic> logData = {
      'endpoint': endpoint,
      'statusCode': statusCode,
      'response': _sanitizeResponse(response),
    };
    i('SUPABASE_RESPONSE', '[$operation] Response', logData);
  }
  
  /// Log a Supabase error
  void logError(String operation, String endpoint, Object error, [StackTrace? stackTrace]) {
    final Map<String, dynamic> logData = {
      'endpoint': endpoint,
      'error': error.toString(),
    };
    e('SUPABASE_ERROR', '[$operation] Error', logData, stackTrace);
  }
  
  /// Formats log messages and sends them to the developer console
  void _log(int level, String tag, String message, [Object? data, StackTrace? stackTrace]) {
    if (level < _currentLogLevel) return;
    
    final String levelStr = _getLevelString(level);
    final String formattedMessage = '$levelStr [$tag] $message';
    
    if (data != null) {
      String dataStr = _formatData(data);
      developer.log('$formattedMessage\n$dataStr', name: 'SupabaseLogger', stackTrace: stackTrace);
    } else {
      developer.log(formattedMessage, name: 'SupabaseLogger', stackTrace: stackTrace);
    }
  }
  
  /// Convert the numeric log level to a string
  String _getLevelString(int level) {
    switch (level) {
      case VERBOSE: return 'VERBOSE';
      case DEBUG: return 'DEBUG';
      case INFO: return 'INFO';
      case WARNING: return 'WARNING';
      case ERROR: return 'ERROR';
      default: return 'UNKNOWN';
    }
  }
  
  /// Format the data object for logging
  String _formatData(Object data) {
    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      } else {
        return data.toString();
      }
    } catch (e) {
      return 'Error formatting data: $e\nOriginal data: $data';
    }
  }
  
  /// Sanitize response data to avoid logging sensitive information
  Object? _sanitizeResponse(Object? response) {
    if (response == null) return null;
    
    try {
      // If the response is a map, sanitize any sensitive fields
      if (response is Map) {
        final Map<String, dynamic> sanitized = Map.from(response as Map);
        
        // List of fields to sanitize
        const sensitiveFields = [
          'password', 'token', 'access_token', 'refresh_token', 'key', 'secret',
          'authorization', 'auth_token', 'jwt', 'apiKey', 'api_key',
        ];
        
        for (final key in sanitized.keys.toList()) {
          final String keyLower = key.toString().toLowerCase();
          
          // Check if this is a sensitive field
          if (sensitiveFields.any((field) => keyLower.contains(field.toLowerCase()))) {
            sanitized[key] = '*** REDACTED ***';
          } 
          // Recursively sanitize nested maps
          else if (sanitized[key] is Map) {
            sanitized[key] = _sanitizeResponse(sanitized[key]);
          }
          // Recursively sanitize maps in lists
          else if (sanitized[key] is List) {
            sanitized[key] = (sanitized[key] as List).map((item) {
              if (item is Map) return _sanitizeResponse(item);
              return item;
            }).toList();
          }
        }
        
        return sanitized;
      }
      
      // If it's a list, sanitize each item in the list that's a map
      if (response is List) {
        return response.map((item) {
          if (item is Map) return _sanitizeResponse(item);
          return item;
        }).toList();
      }
      
      return response;
    } catch (e) {
      return 'Error sanitizing response: $e';
    }
  }
} 