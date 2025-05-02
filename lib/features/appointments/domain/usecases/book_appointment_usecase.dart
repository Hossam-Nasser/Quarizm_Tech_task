import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

class BookAppointmentParams extends Equatable {
  final String specialistId;
  final DateTime appointmentDateTime;

  const BookAppointmentParams({
    required this.specialistId,
    required this.appointmentDateTime,
  });

  @override
  List<Object?> get props => [specialistId, appointmentDateTime];
}

@lazySingleton
class BookAppointmentUseCase {
  final AppointmentRepository repository;

  BookAppointmentUseCase(this.repository);

  Future<Either<Failure, AppointmentEntity>> call(BookAppointmentParams params) {
    return repository.bookAppointment(
      specialistId: params.specialistId,
      appointmentDateTime: params.appointmentDateTime,
    );
  }
}
