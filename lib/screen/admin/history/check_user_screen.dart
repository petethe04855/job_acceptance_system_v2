import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_3/models/check_in_out_history_model.dart';
import 'package:flutter_application_3/services/checkInTime_services.dart';
import 'package:flutter_application_3/themes/colors.dart';

class CheckUserScreen extends StatefulWidget {
  final String uid;
  const CheckUserScreen({super.key, required this.uid});

  @override
  State<CheckUserScreen> createState() => _CheckUserScreenState();
}

class _CheckUserScreenState extends State<CheckUserScreen> {
  final CheckInTimeServices _checkInTimeServices = CheckInTimeServices();
  List<CheckInOutHistoryModel> workHistory = [];
  bool isCheckedIn = false;
  DateTime? checkInTime;

  @override
  void initState() {
    super.initState();
    _loadWorkHistory();
    _loadCheckInStatus();
  }

  Future<void> _loadWorkHistory() async {
    workHistory = await _checkInTimeServices.getWorkHistory(widget.uid);
    setState(() {});
  }

  Future<void> _loadCheckInStatus() async {
    CheckInOutHistoryModel? checkInData = await _checkInTimeServices
        .getCheckInStatus(widget.uid);
    if (checkInData != null && checkInData.checkOutTime == null) {
      setState(() {
        isCheckedIn = true;
        checkInTime = checkInData.checkInTime;
      });
    }
  }

  // void _handleCheckIn(String date) async {
  //   DateTime now = DateTime.now();
  //   await _checkInTimeServices.checkIn(now, date, widget.uid);
  //   setState(() {
  //     isCheckedIn = true;
  //     checkInTime = now;
  //   });
  // }

  // void _handleCheckOut() async {
  //   DateTime now = DateTime.now();
  //   await _checkInTimeServices.checkOut(now, widget.uid);
  //   setState(() {
  //     isCheckedIn = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight, // เปลี่ยนสีพื้นหลังของหน้า
      appBar: AppBar(
        title: const Text(
          'ประวัติการเข้า-ออก',
          style: TextStyle(color: primaryText),
        ),
        backgroundColor: primary,
        iconTheme: IconThemeData(color: primaryText),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
