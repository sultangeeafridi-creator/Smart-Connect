import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  DatabaseReference? _database;

  DatabaseReference get usersRef {
    _database ??= FirebaseDatabase.instance.ref();
    print('Database: Initialized database reference');
    return _database!.child('users');
  }

  // Save user data to Realtime Database
  Future<void> saveUserData({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required int age,
    required String gender,
  }) async {
    try {
      print('Database: Attempting to save user data for userId: $userId');
      print('Database: User data - firstName: $firstName, email: $email');
      
      final ref = usersRef.child(userId);
      print('Database: Reference path: ${ref.path}');
      
      await ref.set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'age': age,
        'gender': gender,
        'createdAt': ServerValue.timestamp,
      });
      
      print('Database: User data saved successfully for user: $userId');
    } catch (e) {
      print('Database Error: Failed to save user data: $e');
      print('Database Error: Error type: ${e.runtimeType}');
      throw Exception('Failed to save user data: $e');
    }
  }

  // Get user data from Realtime Database
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      print('Database: Attempting to get user data for userId: $userId');
      final snapshot = await usersRef.child(userId).get();
      print('Database: Snapshot exists: ${snapshot.exists}');
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        print('Database: User data retrieved for user: $userId');
        print('Database: Retrieved data: $data');
        return Map<String, dynamic>.from(data);
      }
      print('Database: No user data found for user: $userId');
      return null;
    } catch (e) {
      print('Database Error: Failed to get user data: $e');
      throw Exception('Failed to get user data: $e');
    }
  }

  // Update user data
  Future<void> updateUserData({
    required String userId,
    String? firstName,
    String? lastName,
    String? email,
    int? age,
    String? gender,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;
      if (email != null) updates['email'] = email;
      if (age != null) updates['age'] = age;
      if (gender != null) updates['gender'] = gender;
      updates['updatedAt'] = ServerValue.timestamp;

      await usersRef.child(userId).update(updates);
      print('Database: User data updated successfully for user: $userId');
    } catch (e) {
      print('Database Error: Failed to update user data: $e');
      throw Exception('Failed to update user data: $e');
    }
  }

  // Delete user data
  Future<void> deleteUserData(String userId) async {
    try {
      print('Database: Attempting to delete user data for userId: $userId');
      await usersRef.child(userId).remove();
      print('Database: User data deleted for user: $userId');
    } catch (e) {
      print('Database Error: Failed to delete user data: $e');
      throw Exception('Failed to delete user data: $e');
    }
  }

  // Listen to user data changes in real-time
  Stream<Map<String, dynamic>?> watchUserData(String userId) {
    return usersRef.child(userId).onValue.map((event) {
      if (event.snapshot.exists) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        return Map<String, dynamic>.from(data);
      }
      return null;
    });
  }
}
