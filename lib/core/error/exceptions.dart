// Base Exception
class AppException implements Exception {
  final String message;

  AppException({required this.message});
}

// Server Exceptions
class ServerException extends AppException {
  ServerException({required super.message});
}

// Cache Exceptions
class CacheException extends AppException {
  CacheException({required super.message});
}

// Network Exceptions
class NetworkException extends AppException {
  NetworkException({required super.message});
}

// Authentication Exceptions
class AuthException extends AppException {
  AuthException({required super.message});
}

class InvalidCredentialsException extends AuthException {
  InvalidCredentialsException({required super.message});
}

class UserAlreadyExistsException extends AuthException {
  UserAlreadyExistsException({required super.message});
}

class UserNotFoundException extends AuthException {
  UserNotFoundException({required super.message});
}

// Firestore Exceptions
class FirestoreException extends AppException {
  FirestoreException({required super.message});
}

class DocumentNotFoundException extends FirestoreException {
  DocumentNotFoundException({required super.message});
}

class PermissionDeniedException extends FirestoreException {
  PermissionDeniedException({required super.message});
}

class SpecialistNotFoundException extends AppException {
  SpecialistNotFoundException({required super.message});
}

// Appointment Exceptions
class AppointmentException extends AppException {
  AppointmentException({required super.message});
}

class AppointmentAlreadyBookedException extends AppointmentException {
  AppointmentAlreadyBookedException({required super.message});
}

class AppointmentCancellationException extends AppointmentException {
  AppointmentCancellationException({required super.message});
}

class AppointmentReschedulingException extends AppointmentException {
  AppointmentReschedulingException({required super.message});
}
