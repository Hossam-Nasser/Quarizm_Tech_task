import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../repositories/appointment_repository.dart';

@injectable
class IsTimeSlotAvailableUseCase {
  final AppointmentRepository repository;

  IsTimeSlotAvailableUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String specialistId,
    required DateTime dateTime,
  }) {
    return repository.isTimeSlotAvailable(
      specialistId: specialistId,
      dateTime: dateTime,
    );
  }
}
