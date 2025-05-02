import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:quarizmtask/features/appointments/data/services/appointment_services.dart';



import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';

@LazySingleton(as: AppointmentRepository)
class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentServices dataSource;

  AppointmentRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, AppointmentEntity>> bookAppointment({
    required String specialistId,
    required DateTime appointmentDateTime,
  }) async {
    try {
      final appointment = await dataSource.bookAppointment(
        specialistId: specialistId,
        appointmentDateTime: appointmentDateTime,
      );
      return Right(appointment);
    } on AppointmentAlreadyBookedException catch (e) {
      return Left(AppointmentAlreadyBookedFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelAppointment(String appointmentId) async {
    try {
      await dataSource.cancelAppointment(appointmentId);
      return const Right(null);
    } on DocumentNotFoundException catch (e) {
      return Left(DocumentNotFoundFailure(message: e.message));
    } on PermissionDeniedException catch (e) {
      return Left(PermissionDeniedFailure(message: e.message));
    } on AppointmentCancellationException catch (e) {
      return Left(AppointmentCancellationFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDateTime,
  }) async {
    try {
      final appointment = await dataSource.rescheduleAppointment(
        appointmentId: appointmentId,
        newDateTime: newDateTime,
      );
      return Right(appointment);
    } on DocumentNotFoundException catch (e) {
      return Left(DocumentNotFoundFailure(message: e.message));
    } on PermissionDeniedException catch (e) {
      return Left(PermissionDeniedFailure(message: e.message));
    } on AppointmentReschedulingException catch (e) {
      return Left(AppointmentReschedulingFailure(message: e.message));
    } on AppointmentAlreadyBookedException catch (e) {
      return Left(AppointmentAlreadyBookedFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getUserAppointments() async {
    try {
      final appointments = await dataSource.getUserAppointments();
      return Right(appointments);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getUserUpcomingAppointments() async {
    try {
      final appointments = await dataSource.getUserUpcomingAppointments();
      return Right(appointments);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AppointmentEntity>>> getUserPastAppointments() async {
    try {
      final appointments = await dataSource.getUserPastAppointments();
      return Right(appointments);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppointmentEntity>> getAppointmentById(String id) async {
    try {
      final appointment = await dataSource.getAppointmentById(id);
      return Right(appointment);
    } on DocumentNotFoundException catch (e) {
      return Left(DocumentNotFoundFailure(message: e.message));
    } on PermissionDeniedException catch (e) {
      return Left(PermissionDeniedFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isTimeSlotAvailable({
    required String specialistId,
    required DateTime dateTime,
  }) async {
    try {
      final isAvailable = await dataSource.isTimeSlotAvailable(
        specialistId: specialistId,
        dateTime: dateTime,
      );
      return Right(isAvailable);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
