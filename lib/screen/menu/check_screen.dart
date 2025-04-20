// ignore_for_file: avoid_unnecessary_containers, unnecessary_string_interpolations

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_3/models/check_in_out_history_model.dart';
import 'package:flutter_application_3/services/checkInTime_services.dart';

import 'package:flutter_application_3/themes/colors.dart';

class CheckScreen extends StatefulWidget {
  final String uid;
  const CheckScreen({super.key, required this.uid});

  @override
  State<CheckScreen> createState() => _CheckScreenState();
}

class _CheckScreenState extends State<CheckScreen> {
  final CheckInTimeServices _checkInTimeServices = CheckInTimeServices();
  List<CheckInOutHistoryModel> workHistory = [];
  bool isCheckedIn = false;
  DateTime? checkInTime;
  Position? _currentPosition; // เก็บตำแหน่งปัจจุบัน

  @override
  void initState() {
    super.initState();
    _loadWorkHistory();
    _loadCheckInStatus();
    _getCurrentLocation(); // ดึงตำแหน่งตอนเปิดหน้าจอ
  }

  @override
  void dispose() {
    // Any cleanup if necessary
    super.dispose();
  }

  // ฟังก์ชันดึงตำแหน่งปัจจุบัน
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // ตรวจสอบว่าบริการตำแหน่งเปิดใช้งานอยู่หรือไม่
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // ขอสิทธิ์การเข้าถึงตำแหน่ง
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    // ดึงตำแหน่งปัจจุบัน
    Position position = await Geolocator.getCurrentPosition();
    if (mounted) {
      // Check if the widget is still mounted
      setState(() {
        _currentPosition = position;
      });
    }
  }

  Future<void> _loadWorkHistory() async {
    workHistory = await _checkInTimeServices.getWorkHistory(widget.uid);
    if (mounted) {
      // Check if the widget is still mounted
      setState(() {});
    }
  }

  Future<void> _loadCheckInStatus() async {
    CheckInOutHistoryModel? checkInData = await _checkInTimeServices
        .getCheckInStatus(widget.uid);
    if (mounted) {
      // Check if the widget is still mounted
      if (checkInData != null && checkInData.checkOutTime == null) {
        setState(() {
          isCheckedIn = true;
          checkInTime = checkInData.checkInTime;
        });
      }
    }
  }

  void _handleCheckIn(String date) async {
    DateTime now = DateTime.now();
    await _getCurrentLocation(); // ดึงตำแหน่งเมื่อเช็กอิน
    if (_currentPosition != null) {
      await _checkInTimeServices.checkIn(
        now,
        date,
        widget.uid,
        _currentPosition!.latitude, // เก็บ latitude
        _currentPosition!.longitude, // เก็บ longitude
      );
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          isCheckedIn = true;
          checkInTime = now;
        });
      }
    }
  }

  void _handleCheckOut() async {
    DateTime now = DateTime.now();
    await _getCurrentLocation(); // ดึงตำแหน่งเมื่อเช็กเอาต์
    if (_currentPosition != null) {
      await _checkInTimeServices.checkOut(
        now,
        widget.uid,
        _currentPosition!.latitude, // เก็บ latitude
        _currentPosition!.longitude, // เก็บ longitude
      );
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          isCheckedIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMMMMEEEEd('th').format(DateTime.now());

    return Scaffold(
      backgroundColor: backgroundLight, // เปลี่ยนสีพื้นหลังของหน้า
      appBar: AppBar(
        title: const Text('ตอกบัตร', style: TextStyle(color: primaryText)),
        backgroundColor: primary,
        iconTheme: IconThemeData(color: primaryText),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // แสดงรูปภาพสำหรับการตอกบัตร
            Container(
              margin: const EdgeInsets.only(bottom: 24.0),
              child: Image.asset('assets/images/check.png', height: 150),
            ),

            // วันที่
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 16),

            // ปุ่มลงเวลา/ลงออกเวลา
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isCheckedIn
                    ? ElevatedButton(
                      onPressed: _handleCheckOut,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: const Text(
                        "ลงออกเวลา",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    )
                    : ElevatedButton(
                      onPressed: () {
                        _handleCheckIn(formattedDate);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                      ),
                      child: const Text(
                        "ลงเวลา",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
              ],
            ),
            const SizedBox(height: 24),

            // รายการประวัติการลงเวลา
            Expanded(
              child:
                  workHistory.isEmpty
                      ? Center(
                        child: Text(
                          "ไม่มีประวัติการตอกบัตร",
                          style: TextStyle(color: secondaryText, fontSize: 16),
                        ),
                      )
                      : ListView.builder(
                        itemCount: workHistory.length,
                        itemBuilder: (context, index) {
                          CheckInOutHistoryModel history = workHistory[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Card(
                              color: backgroundAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                title: Text(
                                  "วันที่: ${history.date}",
                                  style: const TextStyle(
                                    color: primaryText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "เช็คอิน: ${DateFormat('HH:mm:ss').format(history.checkInTime)}\nเช็คเอาท์: ${history.checkOutTime != null ? DateFormat('HH:mm:ss').format(history.checkOutTime!) : 'ยังไม่ลงเวลาออก'}",
                                  style: const TextStyle(color: secondaryText),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
