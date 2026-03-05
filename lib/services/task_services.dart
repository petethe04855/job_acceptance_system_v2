import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/models/tasks_model.dart';

class TaskServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  var fileNameUploaded;

  var tasks;

  Future<void> uploadProduct(
    File? image,
    String name,
    String description,
  ) async {
    if (image != null && name.isNotEmpty && description.isNotEmpty) {
      final imageUrl = await uploadImage(image);
      if (imageUrl != null) {
        await addTask(name, description, imageUrl);
        print('Product uploaded successfully');
      }
    } else {
      print('Please complete the form');
    }
  }

  Future<void> addTask(String name, String description, String imageUrl) async {
    try {
      DocumentReference docRef = await _firestore.collection('tasks').add({
        'name': name,
        'description': description,
        'imageUrl': imageUrl, // เพิ่ม URL ของรูปภาพ
        'taskStatus': 'รอรับงาน',
        'uidUser': '',
        'quality': 0.0,
        'manners': 0.0,
        'time': 0.0,
        'suggestion': '',
      });
      String taskId = docRef.id; // ดึง ID ของเอกสาร
      print('Task added successfully to Firestore with ID: $taskId');
    } catch (e) {
      print('Error adding task to Firestore: $e');
    }
  }

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
          .child('product_images')
          .child('${DateTime.now().toIso8601String()}');
      await ref.putFile(image);
      final imageUrl = await ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<List<TasksModel>> getTasks() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('tasks').get();
      tasks = querySnapshot.docs.map((doc) {
        final data =
            doc.data() as Map<String, dynamic>; // ✅ ใช้ Map<String, dynamic>

        return TasksModel(
          taskId: doc.id,
          name: data['name'],
          description: data['description'],
          image: data['imageUrl'],
          taskStatus: data['taskStatus'],
          uidUser: data['uidUser'],
          quality: (data['quality'] as num).toDouble(),
          manners: (data['manners'] as num).toDouble(),
          time: (data['time'] as num).toDouble(),
          suggestion: data['suggestion'] ?? '',
          fileName: data.containsKey('fileURL')
              ? data['fileURL']
              : '', // ✅ ป้องกัน Error
        );
      }).toList();

      return tasks;
    } catch (e) {
      print('❌ Error loading tasks: $e');
      return [];
    }
  }

  Future<List<TasksModel>> getTaskStatus(String status) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('tasks')
          .where('taskStatus', isEqualTo: status)
          .get();

      tasks = querySnapshot.docs.map((doc) {
        final data =
            doc.data()
                as Map<
                  String,
                  dynamic
                >; // ✅ ใช้ Map<String, dynamic> ป้องกัน type error

        return TasksModel(
          taskId: doc.id,
          name: data['name'],
          description: data['description'],
          image: data['imageUrl'], // ✅ URL ของรูปภาพ
          taskStatus: data['taskStatus'],
          uidUser: data['uidUser'],
          quality: (data['quality'] as num).toDouble(),
          manners: (data['manners'] as num).toDouble(),
          time: (data['time'] as num).toDouble(),
          suggestion: data['suggestion'] ?? '',
          fileName: data.containsKey('fileURL')
              ? data['fileURL']
              : null, // ✅ ตรวจสอบก่อนดึงค่า
        );
      }).toList();

      return tasks;
    } catch (e) {
      print('❌ Error loading tasks: $e');
      return [];
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      print('Task deleted successfully');
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  Future<void> updateTaskStatus(
    String taskId,
    String taskStatus,
    String? uidUser,
  ) async {
    try {
      print('Updating task with ID: $taskId');
      await _firestore.collection('tasks').doc(taskId).update({
        'taskStatus': taskStatus,
        'uidUser': uidUser,
      });
      print('Task status updated successfully');
    } catch (e) {
      print('Error updating task status: $e');
    }
  }

  // อัปโหลดไฟล์ image word and pdf
  Future<String?> uploadFile(File file) async {
    try {
      String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      Reference ref = _storage.ref('task_files/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      // ดึง URL สำหรับดาวน์โหลด
      String downloadURL = await snapshot.ref.getDownloadURL();
      print('✅ File uploaded: $downloadURL');
      return downloadURL;
    } catch (e) {
      print('❌ Error uploading file: $e');
      return null;
    }
  }

  Future<List<TasksModel>> getTasksByUid(String uid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('tasks')
          .where('uidUser', isEqualTo: uid)
          .where('taskStatus', isEqualTo: 'รับงานแล้ว')
          .get();

      return querySnapshot.docs.map((doc) {
        return TasksModel(
          taskId: doc.id,
          name: doc['name'],
          description: doc['description'],
          image: doc['imageUrl'],
          taskStatus: doc['taskStatus'],
          uidUser: doc['uidUser'],
          quality: (doc['quality'] as num).toDouble(),
          manners: (doc['manners'] as num).toDouble(),
          time: (doc['time'] as num).toDouble(),
          suggestion: doc['suggestion'] ?? '',
          fileName: null, // เพิ่มฟิลด์ fileName
        );
      }).toList();
    } catch (e) {
      print('Error fetching tasks by UID: $e');
      return [];
    }
  }

  Future<List<TasksModel>> getTasksByStatus(String uid) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('tasks')
          .where('uidUser', isEqualTo: uid)
          .get();

      tasks = querySnapshot.docs.map((doc) {
        final data =
            doc.data()
                as Map<
                  String,
                  dynamic
                >; // ✅ ใช้ Map<String, dynamic> ป้องกัน type error

        return TasksModel(
          taskId: doc.id,
          name: data['name'],
          description: data['description'],
          image: data['imageUrl'], // ✅ URL ของรูปภาพ
          taskStatus: data['taskStatus'],
          uidUser: data['uidUser'],
          quality: (data['quality'] as num).toDouble(),
          manners: (data['manners'] as num).toDouble(),
          time: (data['time'] as num).toDouble(),
          suggestion: data['suggestion'] ?? '',
          fileName: data.containsKey('fileURL')
              ? data['fileURL']
              : null, // ✅ ตรวจสอบก่อนดึงค่า
        );
      }).toList();

      return tasks;
    } catch (e) {
      print('Error fetching tasks by UID: $e');
      return [];
    }
  }

  Future<void> upTaskSubmit(
    String taskId,
    double quality,
    double manners,
    double time,
    String suggestion,
  ) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'quality': quality,
        'manners': manners,
        'time': time,
        'taskStatus': 'ผ่านการประเมิน',
        'suggestion': suggestion,
      });
    } catch (e) {
      print('Error updating task in Firestore: $e');
    }
  }

  Future<void> editTask(
    String taskId,
    File? image, // แก้ไขเป็น File? เพื่อรองรับการส่งค่า null ได้
    String name,
    String description,
  ) async {
    String? imageUrl;

    // ตรวจสอบว่ามีการอัปโหลดรูปใหม่หรือไม่
    if (image != null) {
      imageUrl = await uploadImage(image);
    }

    try {
      // เตรียมข้อมูลที่จะอัปเดต
      Map<String, dynamic> updatedData = {
        'name': name,
        'description': description,
      };

      // ถ้ามีการอัปโหลดรูปใหม่ จะเพิ่ม imageUrl เข้าไป
      if (imageUrl != null) {
        updatedData['imageUrl'] = imageUrl;
      }

      // อัปเดตข้อมูลใน Firestore
      await _firestore.collection('tasks').doc(taskId).update(updatedData);

      print('Task updated successfully');
    } catch (e) {
      print('Error updating task in Firestore: $e');
    }
  }

  Future<void> updateTaskStatusTest(
    String taskId,
    String taskStatus,
    String? uidUser,
    FilePickerResult? fileURL,
  ) async {
    try {
      print('🔄 Updating task with ID: $taskId');
      print('🔄 New task status: $taskStatus');
      await _firestore.collection('tasks').doc(taskId).update({
        'taskStatus': taskStatus,
        'uidUser': uidUser,
        'fileURL': fileURL,
      });

      print('✅ Task status updated successfully');
    } catch (e) {
      print('❌ Error updating task status: $e');
    }
  }

  Future<void> updateTaskFileURL(
    String taskId,
    String taskStatus,
    String? uidUser,
    String fileURL,
  ) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'taskStatus': taskStatus,
        'uidUser': uidUser,

        'fileURL': fileURL, // 📌 บันทึกลิงก์ไฟล์ลง Firestore
      });
      print('✅ File URL updated successfully');
    } catch (e) {
      print('❌ Error updating file URL: $e');
    }
  }

  Future<String?> uploadFileTest(String fileName) async {
    try {
      // 📌 แปลงชื่อไฟล์เป็น `File`
      File file = File(fileName); // ใช้ชื่อไฟล์ที่เลือกจาก FilePickerResult

      String filePath =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      Reference ref = _storage.ref('task_files/$filePath');
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        String downloadURL = await snapshot.ref.getDownloadURL();
        print('✅ File uploaded successfully: $downloadURL');
        return downloadURL; // 📌 ส่ง URL ของไฟล์กลับไป
      }
    } catch (e) {
      print('❌ Error uploading file: $e');
    }
    return null;
  }
}
