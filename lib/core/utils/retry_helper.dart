import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';

Future<T> retryWithBackoff<T>(
  Future<T> Function() action, {
  int maxAttempts = 3,
  Duration baseDelay = const Duration(seconds: 1),
}) async {
  int attempt = 0;

  while (true) {
    attempt++;
    try {
      return await action();
    } catch (e) {
      if (attempt >= maxAttempts || !_isRetryable(e)) {
        rethrow;
      }
      final jitter = Random().nextInt(500);
      final delay = baseDelay * pow(2, attempt - 1) + Duration(milliseconds: jitter);
      debugPrint('[RETRY] Intento $attempt fallido, reintentando en ${delay.inMilliseconds}ms');
      await Future.delayed(delay);
    }
  }
}

Future<T> retryWithBackoffAndCheck<T>({
  required Future<T> Function() action,
  required Future<bool> Function() alreadyDone,
  int maxAttempts = 3,
  Duration baseDelay = const Duration(seconds: 1),
}) async {
  int attempt = 0;

  while (true) {
    attempt++;
    try {
      return await action();
    } catch (e) {
      if (attempt >= maxAttempts || !_isRetryable(e)) {
        rethrow;
      }
      final already = await alreadyDone();
      if (already) {
        debugPrint('[RETRY] Operacion ya completada en intento anterior, no reintentando');
        throw RetryNotNeededException();
      }
      final jitter = Random().nextInt(500);
      final delay = baseDelay * pow(2, attempt - 1) + Duration(milliseconds: jitter);
      debugPrint('[RETRY] Intento $attempt fallido, reintentando en ${delay.inMilliseconds}ms');
      await Future.delayed(delay);
    }
  }
}

class RetryNotNeededException implements Exception {
  @override
  String toString() => 'Operacion ya completada, retry innecesario';
}

bool _isRetryable(dynamic error) {
  if (error is SocketException) return true;
  if (error is TimeoutException) return true;
  if (error is HttpException) return true;

  final msg = error.toString().toLowerCase();
  if (msg.contains('timeout')) return true;
  if (msg.contains('timed out')) return true;
  if (msg.contains('connection refused')) return true;
  if (msg.contains('network')) return true;
  if (msg.contains('unreachable')) return true;

  if (error.toString().contains('500') ||
      error.toString().contains('502') ||
      error.toString().contains('503') ||
      error.toString().contains('504')) {
    return true;
  }

  if (error.toString().contains('401') ||
      error.toString().contains('403') ||
      error.toString().contains('409') ||
      error.toString().contains('400')) {
    return false;
  }

  return true;
}

