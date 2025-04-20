import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_3/models/check_in_out_history_model.dart';
import 'package:flutter_application_3/services/user_data_services.dart';

class CheckInTimeServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserDataServices _userDataServices = UserDataServices();

  Future<void> checkIn(
    DateTime checkInTime,
    String formattedDate,
    String uid,
    double latitude,
    double longitude,
  ) async {
    try {
      await _firestore.collection('checkInTimes').add({
        'uid': uid,
        'checkInTime': checkInTime,
        'date': formattedDate,
        'checkOutTime': null,
        'latitude': latitude, // เก็บ latitude
        'longitude': longitude, // เก็บ longitude
      });
      print('Checked in successfully');
    } catch (e) {
      print('Error checking in: $e');
    }
  }

  Future<void> checkOut(
    DateTime checkOutTime,
    String uid,
    double latitude,
    double longitude,
  ) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('checkInTimes')
              .where('uid', isEqualTo: uid)
              .where('checkOutTime', isNull: true)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming the first document is the one to update
        String docId = querySnapshot.docs.first.id;
        await _firestore.collection('checkInTimes').doc(docId).update({
          'checkOutTime': checkOutTime,
        });
        print('Checked out successfully');
      } else {
        print('No check-in record found for check-out');
      }
    } catch (e) {
      print('Error checking out: $e');
    }
  }

  Future<CheckInOutHistoryModel?> getCheckInStatus(String uid) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('checkInTimes')
              .where('uid', isEqualTo: uid)
              .where('checkOutTime', isNull: true)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        return CheckInOutHistoryModel(
          userId: doc['uid'],
          checkInTime: (doc['checkInTime'] as Timestamp).toDate(),
          checkOutTime: null,
          date: doc['date'],
          latitude: doc['latitude'], // เพิ่ม latitude
          longitude: doc['longitude'], // เพิ่ม longitude
        );
      }
    } catch (e) {
      print('Error getting check-in history: $e');
    }
    return null;
  }

  Future<List<CheckInOutHistoryModel>> getWorkHistory(String uid) async {
    List<CheckInOutHistoryModel> workHistory = [];
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('checkInTimes')
              .where('uid', isEqualTo: uid)
              .orderBy('checkInTime', descending: true)
              .get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        workHistory.add(
          CheckInOutHistoryModel(
            userId: data['uid'],
            checkInTime: (data['checkInTime'] as Timestamp).toDate(),
            checkOutTime:
                data['checkOutTime'] != null
                    ? (data['checkOutTime'] as Timestamp).toDate()
                    : null,
            date: data['date'],
            latitude: data['latitude'], // เพิ่ม latitude
            longitude: data['longitude'], // เพิ่ม longitude
          ),
        );
      }
    } catch (e) {
      print('Error getting work history: $e');
    }
    return workHistory;
  }

  Future<List<CheckInOutHistoryModel>> getCheckInOutHistories() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final snapshot = await firestore.collection('checkInTimes').get();

      return Future.wait(
        snapshot.docs.map((doc) async {
          final data = doc.data();
          final userId =
              data['userId'] ?? ''; // ตรวจสอบให้แน่ใจว่า userId ไม่เป็น null

          // ดึงข้อมูลผู้ใช้
          final user = await _userDataServices.getUserById(userId);

          return CheckInOutHistoryModel(
            userId: user!.uid,
            checkInTime: (data['checkInTime'] as Timestamp).toDate(),
            checkOutTime: (data['checkOutTime'] as Timestamp?)?.toDate(),
            date: data['date'] ?? '', // ตรวจสอบให้แน่ใจว่า date ไม่เป็น null
            latitude:
                data['latitude'] ??
                0.0, // ตรวจสอบให้แน่ใจว่า latitude ไม่เป็น null
            longitude:
                data['longitude'] ??
                0.0, // ตรวจสอบให้แน่ใจว่า longitude ไม่เป็น null
          );
        }).toList(),
      );
    } catch (e) {
      print('Error getting check-in history: $e');
      return [];
    }
  }
}

//  Future<List<CheckInOutHistoryModel>> getCheckInOutHistories() async {
//     final firestore = FirebaseFirestore.instance;
//     final snapshot = await firestore.collection('check_in_out_histories').get();

//     return Future.wait(snapshot.docs.map((doc) async {
//       final data = doc.data();
//       final userId = data['userId'] ?? ''; // ตรวจสอบให้แน่ใจว่า userId ไม่เป็น null

//       // ดึงข้อมูลผู้ใช้
//       final user = await getUserById(userId);

//       return CheckInOutHistoryModel(
//         userId: user.uid,
//         checkInTime: (data['checkInTime'] as Timestamp).toDate(),
//         checkOutTime: (data['checkOutTime'] as Timestamp?)?.toDate(),
//         date: data['date'] ?? '', // ตรวจสอบให้แน่ใจว่า date ไม่เป็น null
//       );
//     }).toList());
//   }
