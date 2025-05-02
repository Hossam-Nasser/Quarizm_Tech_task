import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  
  const Failure({required this.message});
  
  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class GeneralFailure extends Failure {
  const GeneralFailure({required super.message});
}

// Auth failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure({required super.message});
}

class UserAlreadyExistsFailure extends AuthFailure {
  const UserAlreadyExistsFailure({required String message}) : super(message: message);
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure({required String message}) : super(message: message);
}

// Firestore failures
class FirestoreFailure extends Failure {
  const FirestoreFailure({required String message}) : super(message: message);
}

class DocumentNotFoundFailure extends FirestoreFailure {
  const DocumentNotFoundFailure({required String message}) : super(message: message);
}

class PermissionDeniedFailure extends FirestoreFailure {
  const PermissionDeniedFailure({required String message}) : super(message: message);
}

// Appointment specific failures
class AppointmentFailure extends Failure {
  const AppointmentFailure({required String message}) : super(message: message);
}

class AppointmentAlreadyBookedFailure extends AppointmentFailure {
  const AppointmentAlreadyBookedFailure({required String message}) : super(message: message);
}

class AppointmentCancellationFailure extends AppointmentFailure {
  const AppointmentCancellationFailure({required String message}) : super(message: message);
}

class AppointmentReschedulingFailure extends AppointmentFailure {
  const AppointmentReschedulingFailure({required String message}) : super(message: message);
}
