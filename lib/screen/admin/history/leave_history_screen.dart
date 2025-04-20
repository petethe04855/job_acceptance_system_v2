import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_3/models/leave_mode.dart';
import 'package:flutter_application_3/screen/admin/history/leave_details/leave_details_screen.dart';
import 'package:flutter_application_3/services/leave_services.dart';
import 'package:flutter_application_3/themes/colors.dart';

class LeaveHistoryScreen extends StatefulWidget {
  final String userId;
  const LeaveHistoryScreen({super.key, required this.userId});

  @override
  State<LeaveHistoryScreen> createState() => _LeaveHistoryScreenState();
}

class _LeaveHistoryScreenState extends State<LeaveHistoryScreen> {
  final LeaveServices _leaveServices = LeaveServices();
  List<LeaveModel> leaveList = [];

  @override
  void initState() {
    super.initState();
    getLeaveList();
  }

  Future<void> getLeaveList() async {
    try {
      List<LeaveModel> fetchedLeaves = await _leaveServices.getLeavesByUserId(
        widget.userId,
      );
      setState(() {
        leaveList = fetchedLeaves;
        print("leaveList : " + leaveList.length.toString());
      });
    } catch (e) {
      print('Error loading leave list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        title: Text('ประวัติการลา', style: TextStyle(color: primaryText)),
        backgroundColor: primary,
        iconTheme: IconThemeData(color: primaryText),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Expanded(
          child:
              leaveList.isEmpty
                  ? Center(
                    child: Text(
                      "ไม่มีประวัติการลา",
                      style: TextStyle(color: secondaryText, fontSize: 16),
                    ),
                  )
                  : ListView.builder(
                    itemCount:
                        leaveList
                            .length, // Assume leaveList is your data source
                    itemBuilder: (context, index) {
                      final leave = leaveList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Card(
                          color: backgroundAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            title: Text(
                              "เหตุผล: ${leave.leaveType}",
                              style: const TextStyle(
                                color: primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "วันที่: ${DateFormat('dd/MM/yyyy').format(leave.date)}",
                              style: const TextStyle(
                                color: secondaryText,
                                fontSize: 14,
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              color: secondaryText,
                            ),
                            onTap: () {
                              // Navigate to leave details screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return LeaveDetailsScreen(leave: leave);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
        ),
        // child: ListView.builder(
        //   itemCount: leaveList.length, // Assume leaveList is your data source
        //   itemBuilder: (context, index) {
        //     final leave = leaveList[index];
        //     return Card(
        //       margin: EdgeInsets.symmetric(vertical: 8.0),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(8.0),
        //       ),
        //       color: backgroundLight,
        //       elevation: 4,
        //       child: ListTile(
        //         contentPadding: EdgeInsets.all(16.0),
        //         title:
        //             Text(leave.leaveType, style: TextStyle(color: primaryText)),
        //         subtitle: Text(
        //           '${leave.date}',
        //           style: TextStyle(color: secondaryText),
        //         ),
        //         trailing: Icon(Icons.arrow_forward_ios, color: secondaryText),
        //         onTap: () {
        //           // Navigate to leave details screen
        //         },
        //       ),
        //     );
        //   },
        // ),
      ),
    );
  }
}
