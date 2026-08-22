import 'app_exception.dart';

/// Immutable value object representing a UI-visible failure state.
/// Used as the error branch in AsyncValue / state notifiers.
///
/// Screens should display [message] to users and optionally inspect
/// [type] for specific recovery actions (e.g. redirect to login on
/// [FailureType.notAuthenticated]).
class Failure {
  const Failure({
    required this.message,
    this.type = FailureType.generic,
    this.originalException,
  });

  final String message;
  final FailureType type;
  final AppException? originalException;

  /// Build a [Failure] directly from any caught exception.
  factory Failure.fromException(Object error) {
    final exception = mapException(error);
    return Failure(
      message: exception.message,
      type: _typeFromException(exception),
      originalException: exception,
    );
  }

  static FailureType _typeFromException(AppException e) => switch (e) {
        NotAuthenticatedException() => FailureType.notAuthenticated,
        ForbiddenException()        => FailureType.forbidden,
        UnauthorizedRoleException() => FailureType.forbidden,
        NetworkException()          => FailureType.network,
        NotFoundException()         => FailureType.notFound,
        InsufficientBalanceException() => FailureType.insufficientBalance,
        _                           => FailureType.generic,
      };

  @override
  String toString() => 'Failure($type): $message';
}

enum FailureType {
  generic,
  notAuthenticated,
  forbidden,
  network,
  notFound,
  insufficientBalance,
}
