import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_3/models/user_model.dart';
import 'package:flutter_application_3/utils/utility.dart';

class UserDataServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var userData;

  Future<List<UserModel>> getUserData() async {
    QuerySnapshot querySnapshot =
        await _firestore
            .collection('Users')
            .where('role', isEqualTo: 'นักศึกษา')
            .get();

    userData =
        querySnapshot.docs.map((doc) {
          return UserModel(
            uid: doc['uid'],
            image: doc['image'],
            firstname: doc['firstname'],
            lastname: doc['lastname'],
            email: doc['email'],
            role: doc['role'],
          );
        }).toList();

    return userData;
  }

  Future<List<UserModel>> getUserDataByRole(String role) async {
    QuerySnapshot querySnapshot =
        await _firestore
            .collection('Users')
            .where('role', isEqualTo: role)
            .get();

    userData =
        querySnapshot.docs.map((doc) {
          return UserModel(
            uid: doc['uid'],
            image: doc['image'],
            firstname: doc['firstname'],
            lastname: doc['lastname'],
            email: doc['email'],
            role: doc['role'],
          );
        }).toList();

    return userData;
  }

  Future<UserModel?> getUserById(String uid) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('Users')
              .where('uid', isEqualTo: uid)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        print('User data: ${doc.data()}');
        return UserModel(
          uid: doc['uid'],
          image: doc['image'],
          firstname: doc['firstname'],
          lastname: doc['lastname'],
          email: doc['email'],
          role: doc['role'],
        );
      }
    } catch (e) {
      Utility().logger.e(e);
    }
    return null;
  }

  Future<void> updateUserData(
    String uid,
    String firstname,
    String lastname,
    String email,
    String role,
  ) async {
    try {
      await _firestore.collection('Users').doc(uid).update({
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'role': role,
      });
      print('User data updated successfully in Firestore');
    } catch (e) {
      print('Error updating user data in Firestore: $e');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      await _firestore.collection('Users').doc(uid).delete();
      print('User deleted successfully from Firestore');
    } catch (e) {
      print('Error deleting user from Firestore: $e');
    }
  }
}
