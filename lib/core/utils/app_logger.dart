import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  static void d(dynamic message) {
    _logger.d(message);
    debugPrint('[DEBUG] $message');
  }

  static void i(dynamic message) {
    _logger.i(message);
    debugPrint('[INFO] $message');
  }

  static void w(dynamic message) {
    _logger.w(message);
    debugPrint('[WARN] $message');
  }

  static void e(dynamic message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    debugPrint('[ERROR] $message ${error ?? ""}');
  }
}


