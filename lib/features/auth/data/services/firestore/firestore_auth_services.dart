import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/error/exceptions.dart';
import '../../models/user_model.dart';
import '../auth_services.dart';

@LazySingleton(as: AuthServices)
class FireStoreAuthServices implements AuthServices {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FireStoreAuthServices(this._firebaseAuth, this._firestore);

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _usersCollection => 
      _firestore.collection('users');

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Create user with Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw FirestoreException(
          message: 'Failed to create user account',
        );
      }
      
      final uid = userCredential.user!.uid;
      final now = DateTime.now();
      
      // Create user document in Firestore
      final userModel = UserModel(
        id: uid,
        email: email,
        name: name,
        createdAt: now,
        updatedAt: now,
      );
      
      // Save user data to Firestore
      await _usersCollection.doc(uid).set(userModel.toJson());
      
      return userModel;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw UserAlreadyExistsException(
          message: 'A user with this email already exists',
        );
      }
      throw FirestoreException(
        message: 'Registration failed: ${e.message}',
      );
    } catch (e) {
      throw FirestoreException(
        message: 'Registration failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw InvalidCredentialsException(
          message: 'Invalid email or password',
        );
      }
      
      final uid = userCredential.user!.uid;
      
      // Fetch user data from Firestore
      final userDoc = await _usersCollection.doc(uid).get();
      
      if (!userDoc.exists) {
        // Create user document if it doesn't exist (in case of auth migration)
        final now = DateTime.now();
        final userModel = UserModel(
          id: uid,
          email: email,
          name: userCredential.user!.displayName ?? 'User',
          createdAt: now,
          updatedAt: now,
        );
        
        await _usersCollection.doc(uid).set(userModel.toJson());
        return userModel;
      }
      
      return UserModel.fromJson(userDoc.data()!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        throw InvalidCredentialsException(
          message: 'Invalid email or password',
        );
      }
      throw FirestoreException(
        message: 'Login failed: ${e.message}',
      );
    } catch (e) {
      throw FirestoreException(
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw FirestoreException(
        message: 'Logout failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      
      if (currentUser == null) {
        return null;
      }
      
      final userDoc = await _usersCollection.doc(currentUser.uid).get();
      
      if (!userDoc.exists) {
        return null;
      }
      
      return UserModel.fromJson(userDoc.data()!);
    } catch (e) {
      throw FirestoreException(
        message: 'Failed to get current user: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? profileImage,
  }) async {
    try {
      final currentUser = _firebaseAuth.currentUser;
      
      if (currentUser == null) {
        throw AuthException(
          message: 'You must be logged in to update your profile',
        );
      }
      
      final uid = currentUser.uid;
      final userDoc = await _usersCollection.doc(uid).get();
      
      if (!userDoc.exists) {
        throw UserNotFoundException(
          message: 'User profile not found',
        );
      }
      
      final existingUser = UserModel.fromJson(userDoc.data()!);
      
      // Update user profile in Firebase Auth if name is provided
      if (name != null) {
        await currentUser.updateDisplayName(name);
      }
      
      // Update user document in Firestore
      final updatedUser = UserModel(
        id: existingUser.id,
        email: existingUser.email,
        name: name ?? existingUser.name,
        profileImage: profileImage ?? existingUser.profileImage,
        createdAt: existingUser.createdAt,
        updatedAt: DateTime.now(),
      );
      
      await _usersCollection.doc(uid).update(updatedUser.toJson());
      
      return updatedUser;
    } catch (e) {
      if (e is AuthException || e is UserNotFoundException) {
        rethrow;
      }
      throw FirestoreException(
        message: 'Failed to update profile: ${e.toString()}',
      );
    }
  }
}
