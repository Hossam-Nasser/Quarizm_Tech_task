import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';


import '../../../../core/error/failure.dart';
import '../entities/specialist_entity.dart';
import '../repositories/specialist_repository.dart';

@injectable
class GetSpecialistByIdUseCase {
  final SpecialistRepository repository;

  GetSpecialistByIdUseCase(this.repository);

  Future<Either<Failure, SpecialistEntity>> call(String id) {
    return repository.getSpecialistById(id);
  }
}
