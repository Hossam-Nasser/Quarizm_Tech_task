import '../models/user_model.dart';

abstract class AuthServices {
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });
  Future<UserModel> login({
    required String email,
    required String password,
  });
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<UserModel> updateProfile({
    String? name,
    String? profileImage,
  });
}
