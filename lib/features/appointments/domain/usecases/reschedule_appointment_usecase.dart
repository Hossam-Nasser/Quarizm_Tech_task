import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

@injectable
class RescheduleAppointmentUseCase {
  final AppointmentRepository repository;

  RescheduleAppointmentUseCase(this.repository);

  Future<Either<Failure, AppointmentEntity>> call({
    required String appointmentId,
    required DateTime newDateTime,
  }) {
    return repository.rescheduleAppointment(
      appointmentId: appointmentId,
      newDateTime: newDateTime,
    );
  }
}
