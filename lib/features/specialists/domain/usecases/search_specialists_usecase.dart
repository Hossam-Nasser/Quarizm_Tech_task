import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failure.dart';
import '../entities/specialist_entity.dart';
import '../repositories/specialist_repository.dart';

@injectable
class SearchSpecialistsUseCase {
  final SpecialistRepository repository;

  SearchSpecialistsUseCase(this.repository);

  Future<Either<Failure, List<SpecialistEntity>>> call(String query) {
    return repository.searchSpecialists(query);
  }
}
