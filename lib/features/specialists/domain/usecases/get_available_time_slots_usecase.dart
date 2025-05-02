import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../repositories/specialist_repository.dart';

class GetAvailableTimeSlotsParams extends Equatable {
  final String specialistId;
  final DateTime date;

  const GetAvailableTimeSlotsParams({
    required this.specialistId,
    required this.date,
  });

  @override
  List<Object?> get props => [specialistId, date];
}

@lazySingleton
class GetAvailableTimeSlotsUseCase {
  final SpecialistRepository repository;

  GetAvailableTimeSlotsUseCase(this.repository);

  Future<Either<Failure, List<DateTime>>> call(GetAvailableTimeSlotsParams params) {
    return repository.getAvailableTimeSlots(
      specialistId: params.specialistId,
      date: params.date,
    );
  }
}
