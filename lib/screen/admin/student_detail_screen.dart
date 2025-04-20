import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/user_model.dart';
import 'package:flutter_application_3/screen/admin/history/check_user_screen.dart';
import 'package:flutter_application_3/screen/admin/history/history_screen.dart';
import 'package:flutter_application_3/screen/admin/history/leave_history_screen.dart';
import 'package:flutter_application_3/themes/colors.dart';

class StudentDetailsScreen extends StatefulWidget {
  final UserModel userDetail;
  const StudentDetailsScreen({super.key, required this.userDetail});

  @override
  State<StudentDetailsScreen> createState() => _StudentDetailsScreenState();
}

class _StudentDetailsScreenState extends State<StudentDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    UserModel user = widget.userDetail;
    return Scaffold(
      backgroundColor: backgroundLight, // เปลี่ยนสีพื้นหลัง
      appBar: AppBar(
        title: Text('User Details', style: TextStyle(color: primaryText)),
        backgroundColor: primary,
        iconTheme: IconThemeData(color: primaryText),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // แสดงภาพโปรไฟล์ผู้ใช้ใน Container ที่ตกแต่ง
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3), // เงา
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    user.image == '' ? '' : user.image,
                  ),
                ),
              ),
              SizedBox(height: 24),

              // ชื่อผู้ใช้
              Text(
                '${user.firstname} ${user.lastname}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryText,
                ),
              ),
              SizedBox(height: 8),

              // บทบาท (Role)
              Text(
                user.role,
                style: TextStyle(fontSize: 18, color: secondaryText),
              ),
              SizedBox(height: 24),

              // ข้อมูลผู้ใช้ใน Card ที่มีการจัดเรียงให้สวยงาม
              Card(
                color: backgroundAccent,
                elevation: 5,
                margin: EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(Icons.email, 'Email', user.email),
                      Divider(color: divider),
                      _buildDetailRow(
                        Icons.person,
                        'Full Name',
                        '${user.firstname} ${user.lastname}',
                      ),
                      Divider(color: divider),
                      _buildDetailRow(Icons.person, 'Role', user.role),
                      Divider(color: divider),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return HistoryScreen(userHistory: user);
                                },
                              ),
                            );
                          },
                          child: Text('ประวัติการรับงาน'),
                        ),
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return LeaveHistoryScreen(userId: user.uid);
                                },
                              ),
                            );
                          },
                          child: Text('ประวัติการลา'),
                        ),
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return CheckUserScreen(uid: user.uid);
                                },
                              ),
                            );
                          },
                          child: Text('ประวัติการลงชื่อเข้า - ออกงาน'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างแถวแสดงรายละเอียด
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: secondary),
        SizedBox(width: 16),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryText,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 16, color: primaryText),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
