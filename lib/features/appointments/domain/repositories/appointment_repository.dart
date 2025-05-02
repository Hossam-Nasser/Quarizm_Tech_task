import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/appointment_entity.dart';

abstract class AppointmentRepository {
  Future<Either<Failure, AppointmentEntity>> bookAppointment({
    required String specialistId,
    required DateTime appointmentDateTime,
  });
  Future<Either<Failure, void>> cancelAppointment(String appointmentId);
  Future<Either<Failure, AppointmentEntity>> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDateTime,
  });
  Future<Either<Failure, List<AppointmentEntity>>> getUserAppointments();
  Future<Either<Failure, List<AppointmentEntity>>> getUserUpcomingAppointments();
  Future<Either<Failure, List<AppointmentEntity>>> getUserPastAppointments();
  Future<Either<Failure, AppointmentEntity>> getAppointmentById(String id);
  Future<Either<Failure, bool>> isTimeSlotAvailable({
    required String specialistId,
    required DateTime dateTime,
  });
}
