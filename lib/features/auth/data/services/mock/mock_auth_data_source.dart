import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';


import '../../../../../core/error/exceptions.dart';
import '../../models/user_model.dart';
import '../auth_services.dart';

@LazySingleton(as: AuthServices)
class MockAuthDataSource implements AuthServices {
  // In-memory storage for mock users
  final Map<String, UserModel> _users = {};
  
  // Current logged in user
  UserModel? _currentUser;
  
  // Constructor to initialize test users
  MockAuthDataSource() {
    // Initialize with test users
    addTestUsers();
  }
  
  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Check if user already exists
    if (_users.values.any((user) => user.email == email)) {
      throw UserAlreadyExistsException(
        message: 'A user with this email already exists',
      );
    }
    
    // Create new user
    final now = DateTime.now();
    final id = const Uuid().v4();
    
    final user = UserModel(
      id: id,
      email: email,
      name: name,
      createdAt: now,
      updatedAt: now,
    );
    
    // Save user to in-memory storage
    _users[id] = user;
    
    // Set as current user
    _currentUser = user;
    
    return user;
  }
  
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Find user by email
    final user = _users.values.firstWhere(
      (user) => user.email == email,
      orElse: () => throw InvalidCredentialsException(
        message: 'Invalid email or password',
      ),
    );
    
    // Set as current user
    _currentUser = user;
    
    return user;
  }
  
  @override
  Future<void> logout() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Clear current user
    _currentUser = null;
  }
  
  @override
  Future<UserModel?> getCurrentUser() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    return _currentUser;
  }
  
  @override
  Future<UserModel> updateProfile({
    String? name,
    String? profileImage,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Check if user is logged in
    if (_currentUser == null) {
      throw AuthException(
        message: 'You must be logged in to update your profile',
      );
    }
    
    // Update user
    final updatedUser = UserModel(
      id: _currentUser!.id,
      email: _currentUser!.email,
      name: name ?? _currentUser!.name,
      profileImage: profileImage ?? _currentUser!.profileImage,
      createdAt: _currentUser!.createdAt,
      updatedAt: DateTime.now(),
    );
    
    // Save updated user
    _users[_currentUser!.id] = updatedUser;
    _currentUser = updatedUser;
    
    return updatedUser;
  }
  
  // Method to pre-populate with test users (for development)
  void addTestUsers() {
    final now = DateTime.now();
    
    // Test user 1
    final user1 = UserModel(
      id: '1',
      email: 'test@example.com',
      name: 'Test User',
      createdAt: now,
      updatedAt: now,
    );
    
    // Test user 2
    final user2 = UserModel(
      id: '2',
      email: 'john@example.com',
      name: 'John Doe',
      profileImage: 'https://randomuser.me/api/portraits/men/32.jpg',
      createdAt: now,
      updatedAt: now,
    );
    
    // Add to in-memory storage
    _users[user1.id] = user1;
    _users[user2.id] = user2;
  }
}
