import 'package:supabase_flutter/supabase_flutter.dart';

/// Base class for all application-level exceptions.
/// Wraps raw Supabase / network errors into typed, user-facing messages.
sealed class AppException implements Exception {
  const AppException(this.message, {this.originalError});

  final String message;
  final Object? originalError;

  @override
  String toString() => 'AppException($runtimeType): $message';
}

// ── Auth exceptions ──────────────────────────────────────────────────────────

final class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException()
      : super('Incorrect email or password. Please try again.');
}

final class EmailAlreadyInUseException extends AppException {
  const EmailAlreadyInUseException()
      : super('An account with this email already exists.');
}

final class WeakPasswordException extends AppException {
  const WeakPasswordException()
      : super('Password must be at least 6 characters.');
}

final class NotAuthenticatedException extends AppException {
  const NotAuthenticatedException()
      : super('You must be signed in to perform this action.');
}

final class ForbiddenException extends AppException {
  const ForbiddenException([String? detail])
      : super(detail ?? 'You do not have permission to perform this action.');
}

final class UnauthorizedRoleException extends AppException {
  const UnauthorizedRoleException(String expectedRole)
      : super('This portal is for $expectedRole accounts only.');
}

// ── Wallet / ticket exceptions ───────────────────────────────────────────────

final class InsufficientBalanceException extends AppException {
  const InsufficientBalanceException()
      : super('Insufficient wallet balance. Please top up and try again.');
}

final class TicketTypeNotFoundException extends AppException {
  const TicketTypeNotFoundException()
      : super('The selected ticket type is no longer available.');
}

final class InvalidTicketException extends AppException {
  const InvalidTicketException(String reason)
      : super('Ticket validation failed: $reason');
}

// ── Database / network exceptions ────────────────────────────────────────────

final class NetworkException extends AppException {
  const NetworkException({Object? originalError})
      : super('No internet connection. Please check your network.',
            originalError: originalError);
}

final class ServerException extends AppException {
  const ServerException([String? detail, Object? originalError])
      : super(detail ?? 'A server error occurred. Please try again.',
            originalError: originalError);
}

final class NotFoundException extends AppException {
  const NotFoundException([String? detail])
      : super(detail ?? 'The requested resource was not found.');
}

final class UnknownException extends AppException {
  const UnknownException(Object error)
      : super('An unexpected error occurred.', originalError: error);
}

// ── Mapper ───────────────────────────────────────────────────────────────────

/// Converts raw Supabase / Dart exceptions into typed [AppException]s.
/// Call this in every catch block in data sources.
AppException mapException(Object error) {
  if (error is AppException) return error;

  if (error is AuthException) {
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid_credentials') ||
        msg.contains('wrong password')) {
      return const InvalidCredentialsException();
    }
    if (msg.contains('user already registered') ||
        msg.contains('already exists')) {
      return const EmailAlreadyInUseException();
    }
    if (msg.contains('password should be at least') ||
        msg.contains('weak_password')) {
      return const WeakPasswordException();
    }
    if (msg.contains('not_authenticated') || msg.contains('not authenticated')) {
      return const NotAuthenticatedException();
    }
    return ServerException(error.message, error);
  }

  if (error is PostgrestException) {
    final msg = error.message.toLowerCase();
    final code = error.code ?? '';

    // RPC-raised exceptions map to their SQLSTATE code string
    if (msg.contains('insufficient_balance')) {
      return const InsufficientBalanceException();
    }
    if (msg.contains('ticket_type_not_found')) {
      return const TicketTypeNotFoundException();
    }
    if (msg.contains('not_authenticated')) {
      return const NotAuthenticatedException();
    }
    if (msg.contains('forbidden')) {
      return const ForbiddenException();
    }
    if (code == '42501' || msg.contains('permission denied')) {
      return const ForbiddenException();
    }
    if (code == 'PGRST116' || msg.contains('not found')) {
      return const NotFoundException();
    }
    return ServerException(error.message, error);
  }

  if (error is StorageException) {
    return ServerException('Storage error: ${error.message}', error);
  }

  // Dart SocketException / network failures
  final str = error.toString().toLowerCase();
  if (str.contains('socketexception') ||
      str.contains('failed host lookup') ||
      str.contains('network is unreachable')) {
    return NetworkException(originalError: error);
  }

  return UnknownException(error);
}
