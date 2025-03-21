# Supabase Logging Utilities

This directory contains utilities for logging Supabase operations in the Playce app. These tools provide detailed insights into API calls, responses, and errors during development and debugging.

## Logging Components

1. **SupabaseLogger** - A general-purpose logging utility that formats and outputs log messages with different severity levels.
2. **SupabaseBlocObserver** - A BLoC observer that logs BLoC events and state changes related to Supabase operations.
3. **LoggingHttpClient** - An HTTP client wrapper that logs the raw HTTP requests and responses for Supabase operations.

## How to Use

### Log Levels

The logging system uses the following log levels:

- `VERBOSE` (0) - Detailed debugging information (very noisy)
- `DEBUG` (1) - Useful debugging information
- `INFO` (2) - General information about app operation
- `WARNING` (3) - Potential issues that aren't errors
- `ERROR` (4) - Errors and exceptions

### Setup

The logging system is configured in `main.dart`:

```dart
// Set log level
SupabaseLogger().setLogLevel(SupabaseLogger.DEBUG);

// Register custom BLoC observer
Bloc.observer = SupabaseBlocObserver();
```

### Viewing Logs

Use the following technique to see the logs in the console:

1. For general development:

```bash
flutter run --verbose
```

2. For even more detailed logs:

```bash
flutter run --verbose --debug
```

3. To save logs to a file:

```bash
flutter run --verbose > supabase_logs.txt 2>&1
```

### Log Format

The logs follow this general format:

```
[LOG_LEVEL] [TAG] Message
{JSON data if applicable}
```

Example:

```
INFO [SUPABASE_REQUEST] [SIGN_IN] Request
{
  "endpoint": "auth.signInWithPassword",
  "data": {
    "email": "user@example.com"
  }
}
```

## Troubleshooting Common Issues

If you're experiencing issues with Supabase operations, check for:

1. **Authentication errors** - Look for logs with `SUPABASE_ERROR` or `AUTH_SIGN_IN` tags
2. **Network issues** - Check for HTTP status codes in `SUPABASE_RESPONSE` logs
3. **Data problems** - Examine the request/response payloads in logs for incorrect data formats

## Production Considerations

For production builds, you should increase the log level to reduce verbosity:

```dart
// In main.dart
SupabaseLogger().setLogLevel(SupabaseLogger.WARNING);
```

To completely disable logging in production, you can use the release mode configuration:

```dart
// In main.dart
bool isDebug = !kReleaseMode;
SupabaseLogger().setLogLevel(isDebug ? SupabaseLogger.DEBUG : SupabaseLogger.ERROR);
```

## Contributing

When adding new Supabase functionality, make sure to incorporate appropriate logging using the `SupabaseLogger` class:

```dart
final logger = SupabaseLogger();

// Log information
logger.i('TAG', 'This is an info message', {/* optional data */});

// Log errors with stack trace
try {
  // Operation that might fail
} catch (e, stackTrace) {
  logger.e('TAG', 'Operation failed', e, stackTrace);
  rethrow;
}
``` 