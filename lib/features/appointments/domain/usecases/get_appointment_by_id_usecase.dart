import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

@injectable
class GetAppointmentByIdUseCase {
  final AppointmentRepository repository;

  GetAppointmentByIdUseCase(this.repository);

  Future<Either<Failure, AppointmentEntity>> call(String id) {
    return repository.getAppointmentById(id);
  }
}
