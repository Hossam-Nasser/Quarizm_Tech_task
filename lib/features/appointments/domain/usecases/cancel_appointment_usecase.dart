import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../repositories/appointment_repository.dart';

@injectable
class CancelAppointmentUseCase {
  final AppointmentRepository repository;

  CancelAppointmentUseCase(this.repository);

  Future<Either<Failure, void>> call(String appointmentId) {
    return repository.cancelAppointment(appointmentId);
  }
}
