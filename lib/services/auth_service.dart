import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Create user document in Firestore
        final userData = {
          'name': name,
          'email': email,
          'role': 'employee', // Force employee role
          'verified': false,
          'leaveBalance': {
            'paidLeave': AppConstants.defaultPaidLeaves,
            'sickLeave': AppConstants.defaultSickLeaves,
            'earnedLeave': 0,
          },
        };
        try {
          print('Attempting to write user data to Firestore: $userData');
          await _firestore.collection('users').doc(user.uid).set(userData);
          print('User document created in Firestore for UID: ${user.uid}');
          return UserModel(
            name: name,
            email: email,
            role: 'employee',
            verified: false,
            leaveBalance: const LeaveBalance(
              paidLeave: AppConstants.defaultPaidLeaves,
              sickLeave: AppConstants.defaultSickLeaves,
              earnedLeave: 0,
            ),
          );
        } catch (e) {
          print('Error writing to Firestore: $e');
          rethrow;
        }
      }
      return null;
    } catch (e) {
      print('Error during signup: $e');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Fetch user data from Firestore
        DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        } else {
          print('No user document found for UID: ${user.uid}');
          throw Exception('User data not found in Firestore. Please sign up first.');
        }
      }
      return null;
    } catch (e) {
      print('Error during sign-in: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}