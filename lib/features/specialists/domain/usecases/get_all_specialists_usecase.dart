import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';



import '../../../../core/error/failure.dart';
import '../entities/specialist_entity.dart';
import '../repositories/specialist_repository.dart';

@lazySingleton
class GetAllSpecialistsUseCase {
  final SpecialistRepository repository;

  GetAllSpecialistsUseCase(this.repository);

  Future<Either<Failure, List<SpecialistEntity>>> call() {
    return repository.getAllSpecialists();
  }
}
