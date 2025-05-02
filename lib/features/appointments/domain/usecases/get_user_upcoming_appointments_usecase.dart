import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

@injectable
class GetUserUpcomingAppointmentsUseCase {
  final AppointmentRepository repository;

  GetUserUpcomingAppointmentsUseCase(this.repository);

  Future<Either<Failure, List<AppointmentEntity>>> call() {
    return repository.getUserUpcomingAppointments();
  }
}
