import 'package:equatable/equatable.dart';

/// Base failure class for error handling
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

/// Server/API related failures
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Network/Connection failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Cache/Local storage failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Failed to access local data.',
    super.code = 'CACHE_ERROR',
  });
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
  });

  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: 'Invalid email or password.',
        code: 'INVALID_CREDENTIALS',
      );

  factory AuthFailure.sessionExpired() => const AuthFailure(
        message: 'Your session has expired. Please login again.',
        code: 'SESSION_EXPIRED',
      );

  factory AuthFailure.biometricFailed() => const AuthFailure(
        message: 'Biometric authentication failed.',
        code: 'BIOMETRIC_FAILED',
      );
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Payment failures
class PaymentFailure extends Failure {
  const PaymentFailure({
    required super.message,
    super.code,
  });

  factory PaymentFailure.cancelled() => const PaymentFailure(
        message: 'Payment was cancelled.',
        code: 'PAYMENT_CANCELLED',
      );

  factory PaymentFailure.failed() => const PaymentFailure(
        message: 'Payment failed. Please try again.',
        code: 'PAYMENT_FAILED',
      );

  factory PaymentFailure.insufficientFunds() => const PaymentFailure(
        message: 'Insufficient funds in your account.',
        code: 'INSUFFICIENT_FUNDS',
      );
}

/// Trading failures
class TradingFailure extends Failure {
  const TradingFailure({
    required super.message,
    super.code,
  });

  factory TradingFailure.marketClosed() => const TradingFailure(
        message: 'Markets are closed. Trading hours: 9:30 AM - 4:00 PM EST.',
        code: 'MARKET_CLOSED',
      );

  factory TradingFailure.insufficientBalance() => const TradingFailure(
        message: 'Insufficient balance to complete this trade.',
        code: 'INSUFFICIENT_BALANCE',
      );

  factory TradingFailure.orderFailed() => const TradingFailure(
        message: 'Order could not be executed. Please try again.',
        code: 'ORDER_FAILED',
      );
}

/// KYC failures
class KYCFailure extends Failure {
  const KYCFailure({
    required super.message,
    super.code,
  });

  factory KYCFailure.documentRejected(String reason) => KYCFailure(
        message: 'Document rejected: $reason',
        code: 'DOCUMENT_REJECTED',
      );

  factory KYCFailure.verificationPending() => const KYCFailure(
        message: 'Your verification is still pending.',
        code: 'VERIFICATION_PENDING',
      );
}
