import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_3/models/user_model.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<String?> uploadImage(File image) async {
    try {
      final ref = _storage
          .ref()
          .child('imagesByUser')
          .child('${DateTime.now().toIso8601String()}');
      await ref.putFile(image);
      final imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<User?> sigUpWithEmailAndPassWord(
    String email,
    File? image,
    String password,
    String confirmPassword,
    String firstname,
    String lastname,
    // String role,
  ) async {
    try {
      if (password != confirmPassword || image != null) {
        final imageUrl = await uploadImage(image!);

        UserCredential credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(credential.user!.uid)
            .set({
              'uid': credential.user!.uid,
              'image': imageUrl,
              'email': email,
              'firstname': firstname,
              'lastname': lastname,
              'role': "นักศึกษา",
            });

        return credential.user;
      }

      // UserCredential credential =
      //     await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );
      // await FirebaseFirestore.instance
      //     .collection('Users')
      //     .doc(credential.user!.uid)
      //     .set({
      //   'uid': credential.user!.uid,
      //   'image': ,
      //   'email': email,
      //   'firstname': firstname,
      //   'lastname': lastname,
      //   'role': "นักศึกษา",
      // });

      // await FirebaseFirestore.instance.collection('Users').add({
      //   'uid': credential.user!.uid,
      //   'email': email,
      //   'firstname': firstname,
      //   'lastname': lastname,
      //   'role': "นักศึกษา",
      // });
    } on FirebaseAuthException catch (e) {
      print("Error: ${e.message}");
      return null;
    }
  }

  Future<String?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // การลงชื่อเข้าใช้สำเร็จไม่มี error
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        return 'รหัสผ่านผิด';
      } else if (e.code == 'user-not-found') {
        return 'ไม่พบผู้ใช้';
      } else if (e.code == 'invalid-email') {
        return 'ไม่พบอีเมล';
      } else {
        return 'Error: ${e.message}';
      }
    } catch (e) {
      return 'Unexpected error: $e';
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserModel?> getUser() async {
    try {
      DocumentSnapshot doc =
          await _firestore
              .collection('Users')
              .doc(_auth.currentUser!.uid)
              .get();
      if (doc.exists) {
        return UserModel(
          uid: doc.id,
          image: doc['image'],
          email: doc['email'],
          firstname: doc['firstname'],
          lastname: doc['lastname'],
          role: doc['role'],
        );
      }
    } catch (e) {
      print('Error fetching user: $e');
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
