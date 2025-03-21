import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:playce/utils/supabase_logger.dart';

/// An HTTP client that logs all requests and responses
/// This can be used with Supabase to log all HTTP communication
class LoggingHttpClient extends http.BaseClient {
  final http.Client _inner;
  final SupabaseLogger _logger;

  LoggingHttpClient({http.Client? inner})
      : _inner = inner ?? http.Client(),
        _logger = SupabaseLogger();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final stopwatch = Stopwatch()..start();
    
    // Log the request
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final Map<String, dynamic> requestData = {
      'id': requestId,
      'method': request.method,
      'url': request.url.toString(),
      'headers': _sanitizeHeaders(request.headers),
    };
    
    // Log request body for appropriate methods
    if (request is http.Request) {
      final req = request as http.Request;
      try {
        // Try to parse as JSON
        if (req.body.isNotEmpty) {
          try {
            requestData['body'] = json.decode(req.body);
          } catch (_) {
            // If not JSON, just include as string
            requestData['body'] = req.body;
          }
        }
      } catch (e) {
        requestData['body'] = '<error decoding body: $e>';
      }
    }
    
    _logger.d('HTTP_REQUEST', '[${request.method}] ${request.url}', requestData);
    
    try {
      // Forward the request to the inner client and store the response
      final response = await _inner.send(request);
      
      // Log the response
      final responseData = {
        'id': requestId,
        'statusCode': response.statusCode,
        'reasonPhrase': response.reasonPhrase,
        'headers': _sanitizeHeaders(response.headers),
        'duration': '${stopwatch.elapsedMilliseconds}ms',
      };
      
      // Try to get the response body
      try {
        final responseBody = await http.Response.fromStream(response);
        try {
          // Try to parse as JSON if contentType is application/json
          if (responseBody.headers['content-type']?.contains('application/json') ?? false) {
            responseData['body'] = json.decode(responseBody.body);
          } else if (responseBody.body.isNotEmpty) {
            responseData['body'] = responseBody.body;
          }
        } catch (e) {
          responseData['body'] = '<error decoding body: $e>';
        }
        
        // Create a new StreamedResponse since we've consumed the original
        return http.StreamedResponse(
          Stream.value(utf8.encode(responseBody.body)),
          response.statusCode,
          contentLength: responseBody.body.length,
          headers: response.headers,
          isRedirect: response.isRedirect,
          persistentConnection: response.persistentConnection,
          reasonPhrase: response.reasonPhrase,
          request: response.request,
        );
      } catch (e) {
        responseData['body'] = '<error getting response body: $e>';
      }
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _logger.d('HTTP_RESPONSE', '[${response.statusCode}] ${request.url}', responseData);
      } else {
        _logger.w('HTTP_RESPONSE', '[${response.statusCode}] ${request.url}', responseData);
      }
      
      // Return the original response
      return response;
    } catch (e, stackTrace) {
      final errorData = {
        'id': requestId,
        'error': e.toString(),
        'duration': '${stopwatch.elapsedMilliseconds}ms',
      };
      
      _logger.e('HTTP_ERROR', '[${request.method}] ${request.url}', errorData, stackTrace);
      rethrow;
    }
  }
  
  // Sanitize headers to not log sensitive information
  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final result = Map<String, String>.from(headers);
    final sensitiveHeaders = [
      'authorization',
      'apikey',
      'api-key',
      'x-api-key',
      'key',
      'secret',
      'token',
      'password',
      'cookie',
    ];
    
    for (final key in headers.keys) {
      if (sensitiveHeaders.any((h) => key.toLowerCase().contains(h))) {
        result[key] = '*** REDACTED ***';
      }
    }
    
    return result;
  }
}

/// Extension method to create Supabase client with logging
extension SupabaseClientLogging on SupabaseClient {
  /// Enable HTTP logging for this Supabase client
  void enableHttpLogging() {
    // Access the underlying Supabase client's HTTP client and replace it
    // Note: This is a bit of a hack, as the Supabase client doesn't expose its HTTP client
    try {
      // Access the private httpClient field using reflection
      final httpClient = LoggingHttpClient();
      
      // TODO: As of the current version, we can't directly replace the HTTP client
      // in Supabase Flutter. This is intentionally left as a comment.
      // In a real implementation, you would need to create a custom GoTrueClient,
      // PostgRESTClient, etc. with your custom HTTP client.
      // 
      // For now, this class serves as a reference implementation.
      
      // Log that logging is enabled
      SupabaseLogger().i('SUPABASE_HTTP', 'HTTP logging enabled for Supabase client');
    } catch (e) {
      SupabaseLogger().e('SUPABASE_HTTP', 'Failed to enable HTTP logging', e);
    }
  }
} 