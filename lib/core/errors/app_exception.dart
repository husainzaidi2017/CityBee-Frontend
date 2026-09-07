/// User-facing application failures.
///
/// Repositories and services translate technical exceptions into these; the
/// UI renders [userMessage] so raw errors never reach users.
sealed class AppException implements Exception {
  const AppException(this.userMessage, [this.cause]);

  final String userMessage;
  final Object? cause;
}

final class NetworkException extends AppException {
  const NetworkException([super.cause])
      : super('No internet connection. Please check your network and retry.');
}

final class ServerException extends AppException {
  const ServerException([super.cause]) : super('Something went wrong. Please try again.');
}

final class LocationPermissionException extends AppException {
  const LocationPermissionException([super.cause])
      : super('Location permission is off. Enable it to see nearby places, or pick a city manually.');
}

final class NotFoundException extends AppException {
  const NotFoundException([super.cause]) : super('This listing is no longer available.');
}
