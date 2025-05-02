import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../repositories/specialist_repository.dart';

@injectable
class GetAllSpecializationsUseCase {
  final SpecialistRepository repository;

  GetAllSpecializationsUseCase(this.repository);

  Future<Either<Failure, List<String>>> call() {
    return repository.getAllSpecializations();
  }
}
