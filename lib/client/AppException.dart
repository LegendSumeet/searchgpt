abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
  @override
  String toString() => message;
}

class NoInternetException extends AppException {
  NoInternetException(super.message);
}

class TimeoutException extends AppException {
  TimeoutException(super.message);
}

class ServerException extends AppException {
  ServerException(super.message);
}

class BadRequestException extends AppException {
  BadRequestException(super.message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message);
}

class NotFoundException extends AppException {
  NotFoundException(super.message);
}

class RequestCancelledException extends AppException {
  RequestCancelledException(super.message);
}

class UnknownException extends AppException {
  UnknownException(super.message);
}
