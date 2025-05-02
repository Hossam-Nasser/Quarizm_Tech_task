import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {

  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });


  Future<Either<Failure, void>> logout();


  Future<Either<Failure, UserEntity?>> getCurrentUser();


  Future<Either<Failure, UserEntity>> updateProfile({
    String? name,
    String? profileImage,
  });
}
