import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/specialist_entity.dart';
import '../repositories/specialist_repository.dart';

@injectable
class GetSpecialistsBySpecializationUseCase {
  final SpecialistRepository repository;

  GetSpecialistsBySpecializationUseCase(this.repository);

  Future<Either<Failure, List<SpecialistEntity>>> call(String specialization) {
    return repository.getSpecialistsBySpecialization(specialization);
  }
}
