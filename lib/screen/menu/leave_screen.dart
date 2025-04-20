import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/components/custom_textfield.dart';
import 'package:flutter_application_3/models/leave_mode.dart';
import 'package:flutter_application_3/services/leave_services.dart';
import 'package:flutter_application_3/themes/colors.dart';
import 'package:flutter_application_3/utils/utility.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  LeaveServices _leaveServices = LeaveServices();
  Utility _utility = Utility();

  List<LeaveModel> _leaves = [];
  List<LeaveModel> _leavesByUserId = [];

  final _leave = TextEditingController();
  String _selectedLeaveType = 'เลือกประเภทการลา';

  final List<String> _leaveTypes = [
    'เลือกประเภทการลา',
    'ลาป่วย',
    'ลาคลอดบุตร',
    'ลาพักร้อน',
    'ลากิจส่วนตัว',
    'ลาไปศึกษา ฝึกอบรม ดูงาน',
    'ลาไปปฏิบัติงานในองค์การระหว่างประเทศ',
    'ลาสมรส',
  ];

  @override
  void initState() {
    super.initState();
    _loadPendingLeaves();
    _loadLeavesByUserId();
  }

  Future<void> _loadLeavesByUserId() async {
    try {
      var fetchedLeaves = await _leaveServices.getLeavesByUserId(
        _auth.currentUser!.uid,
      );
      setState(() {
        _leavesByUserId = fetchedLeaves;
      });
    } catch (e) {
      _utility.logger.e('Error loading leaves: $e');
    }
  }

  Future<void> _loadPendingLeaves() async {
    try {
      var pendingLeaves = await _leaveServices.getPendingLeaves();
      setState(() {
        _leaves = pendingLeaves;
      });
    } catch (e) {
      print('Error loading pending leaves: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("id: ${_auth.currentUser!.uid}");

    // ตรวจสอบว่ามีคำขอลาที่รอการอนุมัติอยู่หรือไม่
    bool isPendingApproval = _leaves.any(
      (leave) => leave.status == 'รอการตอบรับ',
    );

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text('ลางาน'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ประวัติการลา",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 200, // ความสูงสูงสุดของ ListView
                ),
                child:
                    _leavesByUserId.isEmpty
                        ? Center(
                          child: Text(
                            "ไม่มีข้อมูล",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        )
                        : ListView.builder(
                          itemCount: _leavesByUserId.length,
                          itemBuilder: (context, index) {
                            LeaveModel leave = _leavesByUserId[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                title: Text(
                                  leave.reason,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text("ประเภทการลา: ${leave.leaveType}"),
                                    Text("สถานะ: ${leave.status}"),
                                    Text(
                                      "วันที่: ${leave.date.toString()}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
              const SizedBox(height: 20),
              const Text(
                "สถานะการลา (รอการอนุมัติ)",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _leaves.isEmpty
                  ? Center(
                    child: Text(
                      "ไม่มีคำขอลาที่รอการตอบรับ",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                  : Card(
                    child: ListTile(
                      title: Text(
                        "คุณมีคำขอลาที่รอการอนุมัติ",
                        style: TextStyle(color: Colors.black),
                      ),
                      subtitle: Text("กรุณารอการตอบรับ"),
                    ),
                  ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedLeaveType,
                onChanged: (newValue) {
                  setState(() {
                    _selectedLeaveType = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'ประเภทการลา',
                  filled: true,
                  fillColor: backgroundText,
                  labelStyle: const TextStyle(color: primaryText),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 15.0,
                    horizontal: 10.0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(width: 2.0),
                  ),
                ),
                items:
                    _leaveTypes.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),
              customTextFormFieldDetails(
                controller: _leave,
                hintText: "เหตุผล",
                maxLines: 6,
                prefixIcon: null,
                textStyleColor: backgroundText,
                onTap: () {},
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed:
                      isPendingApproval
                          ? null // ปิดการใช้งานปุ่มถ้ามีคำขอลาที่รอการอนุมัติ
                          : () {
                            if (_selectedLeaveType == 'เลือกประเภทการลา') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('กรุณาเลือกประเภทการลา'),
                                ),
                              );
                            } else {
                              _leaveServices.createLeave(
                                _selectedLeaveType,
                                _leave.text,
                              );
                              Navigator.pop(context);
                            }
                          },
                  child: const Text('บันทึก', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
