import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_3/models/leave_mode.dart';

class LeaveServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  var userData;

  Future<LeaveModel?> createLeave(String leaveType, String reason) async {
    try {
      User? user = _auth.currentUser;
      await _firestore.collection('Leave').doc().set({
        'userId': user!.uid,
        'leaveType': leaveType,
        'reason': reason,
        'status': 'รอการตอบรับ',
        'date': DateTime.now(),
      });
    } catch (e) {
      print('Error creating leave: $e');
    }
    return null;
  }

  Future<List<LeaveModel>> getLeavesByUserId(String userId) async {
    try {
      var querySnapshot =
          await _firestore
              .collection('Leave')
              .where('userId', isEqualTo: userId)
              .get();
      List<LeaveModel> leaves = [];
      for (var doc in querySnapshot.docs) {
        leaves.add(
          LeaveModel(
            userId: doc['userId'],
            leaveType: doc['leaveType'],
            reason: doc['reason'],
            status: doc['status'],
            date: (doc['date'] as Timestamp).toDate(),
          ),
        );
      }

      return leaves;
    } catch (e) {
      print('Error getting leaves: $e');
    }
    return [];
  }

  Future<List<LeaveModel>> getLeavesByStatus() async {
    try {
      var querySnapshot =
          await _firestore
              .collection('Leave')
              .where('status', isEqualTo: "รอการตอบรับ")
              .get();
      List<LeaveModel> leaves = [];
      for (var doc in querySnapshot.docs) {
        leaves.add(
          LeaveModel(
            userId: doc['userId'],
            leaveType: doc['leaveType'],
            reason: doc['reason'],
            status: doc['status'],
            date: (doc['date'] as Timestamp).toDate(),
          ),
        );
      }

      return leaves;
    } catch (e) {
      print('Error getting leaves: $e');
    }
    return [];
  }

  Future<List<LeaveModel>> getLeaves() async {
    try {
      var querySnapshot = await _firestore.collection('Leave').get();
      List<LeaveModel> leaves = [];
      for (var doc in querySnapshot.docs) {
        leaves.add(
          LeaveModel(
            userId: doc['userId'],
            leaveType: doc['leaveType'],
            reason: doc['reason'],
            status: doc['status'],
            date: (doc['date'] as Timestamp).toDate(),
          ),
        );
      }

      return leaves;
    } catch (e) {
      print('Error getting leaves: $e');
    }
    return [];
  }

  Future<void> updateLeaveStatusByUid(String uid) async {
    try {
      // ค้นหาเอกสารที่มี uid ตรงกับค่าที่ระบุ
      var querySnapshot =
          await _firestore
              .collection('Leave')
              .where('userId', isEqualTo: uid)
              .get();

      // อัปเดตสถานะสำหรับเอกสารที่ค้นพบ
      for (var doc in querySnapshot.docs) {
        await _firestore.collection('Leave').doc(doc.id).update({
          'status': 'อนุมัติ',
        });
      }
    } catch (e) {
      print('Error updating leave status: $e');
    }
  }

  Future<void> getLeaveByUid(String uid) async {
    try {
      await _firestore
          .collection('Leave')
          .where('userId', isEqualTo: uid)
          .get();
    } catch (e) {
      print('Error updating leave status: $e');
    }
  }

  // ดึงคำขอลาที่รอการตอบรับ
  Future<List<LeaveModel>> getPendingLeaves() async {
    try {
      var querySnapshot =
          await _firestore
              .collection('Leave')
              .where('userId', isEqualTo: _auth.currentUser!.uid)
              .where('status', isEqualTo: 'รอการตอบรับ')
              .get();

      return querySnapshot.docs.map((doc) {
        return LeaveModel(
          userId: doc['userId'],
          leaveType: doc['leaveType'],
          status: doc['status'],
          reason: doc['reason'],
          date: (doc['date'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      print('Error getting pending leaves: $e');
      return [];
    }
  }
}
