import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';



import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/specialist_entity.dart';
import '../../domain/repositories/specialist_repository.dart';
import '../services/specialist_services.dart';

@LazySingleton(as: SpecialistRepository)
class SpecialistRepositoryImpl implements SpecialistRepository {
  final SpecialistServices services;

  SpecialistRepositoryImpl(this.services);

  @override
  Future<Either<Failure, List<SpecialistEntity>>> getAllSpecialists() async {
    try {
      final specialists = await services.getAllSpecialists();
      return Right(specialists);
    } on FirestoreException catch (e) {
      return Left(FirestoreFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<
      Either<Failure, List<SpecialistEntity>>> getSpecialistsBySpecialization(
      String specialization) async {
    try {
      final specialists = await services.getSpecialistsBySpecialization(
          specialization);
      return Right(specialists);
    } on FirestoreException catch (e) {
      return Left(FirestoreFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SpecialistEntity>> getSpecialistById(String id) async {
    try {
      final specialist = await services.getSpecialistById(id);
      return Right(specialist);
    } on DocumentNotFoundException catch (e) {
      return Left(DocumentNotFoundFailure(message: e.message));
    } on FirestoreException catch (e) {
      return Left(FirestoreFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getAllSpecializations() async {
    try {
      final specializations = await services.getAllSpecializations();
      return Right(specializations);
    } on FirestoreException catch (e) {
      return Left(FirestoreFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SpecialistEntity>>> searchSpecialists(
      String query) async {
    try {
      final specialists = await services.searchSpecialists(query);
      return Right(specialists);
    } on FirestoreException catch (e) {
      return Left(FirestoreFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DateTime>>> getAvailableTimeSlots({
    required String specialistId,
    required DateTime date,
  }) async {
    try {
      final timeSlots = await services.getAvailableTimeSlots(
        specialistId: specialistId,
        date: date,
      );
      return Right(timeSlots);
    } on DocumentNotFoundException catch (e) {
      return Left(DocumentNotFoundFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
    // } on AppException catch (e) {
    //   return Left(Failure(message: e.message));
    // } catch (e) {
    //  return Left(ServerFailure(message: e.toString()));
  }
}
