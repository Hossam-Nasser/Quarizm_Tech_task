import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/specialist_entity.dart';

abstract class SpecialistRepository {
  Future<Either<Failure, List<SpecialistEntity>>> getAllSpecialists();
  Future<Either<Failure, List<SpecialistEntity>>> getSpecialistsBySpecialization(String specialization);
  Future<Either<Failure, SpecialistEntity>> getSpecialistById(String id);
  Future<Either<Failure, List<String>>> getAllSpecializations();
  Future<Either<Failure, List<SpecialistEntity>>> searchSpecialists(String query);
  Future<Either<Failure, List<DateTime>>> getAvailableTimeSlots({
    required String specialistId,
    required DateTime date,
  });
}
