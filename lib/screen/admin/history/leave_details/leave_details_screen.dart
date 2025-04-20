import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_3/models/leave_mode.dart';
import 'package:flutter_application_3/themes/colors.dart';

class LeaveDetailsScreen extends StatefulWidget {
  final LeaveModel leave;
  const LeaveDetailsScreen({super.key, required this.leave});

  @override
  State<LeaveDetailsScreen> createState() => _LeaveDetailsScreenState();
}

class _LeaveDetailsScreenState extends State<LeaveDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final LeaveModel leave = widget.leave;
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดการลา', style: TextStyle(color: primaryText)),
        iconTheme: IconThemeData(color: primaryText),
        backgroundColor: primary,
      ),
      backgroundColor: backgroundLight,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ประเภทการลา: ${leave.leaveType}',
              style: TextStyle(color: primaryText, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'เหตุผล: ${leave.reason}',
              style: TextStyle(color: secondaryText),
            ),
            SizedBox(height: 16),
            Text(
              'วันที่เริ่มต้น: ${DateFormat('dd/MM/yyyy').format(leave.date)}',
              style: TextStyle(color: backgroundText),
            ),
            SizedBox(height: 8),
            Divider(color: divider),
            SizedBox(height: 16),
            Text(
              'สถานะ: ${leave.status}',
              style: TextStyle(color: secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
