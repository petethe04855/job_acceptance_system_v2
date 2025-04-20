// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/tasks_model.dart';
import 'package:flutter_application_3/models/user_model.dart';
import 'package:flutter_application_3/screen/admin/admin_submit_work.dart';
import 'package:flutter_application_3/screen/admin/edit_screen.dart';
import 'package:flutter_application_3/services/user_data_services.dart';
import 'package:flutter_application_3/themes/colors.dart';
import 'package:flutter_application_3/utils/utility.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminJobScreen extends StatefulWidget {
  final TasksModel tasksData;
  final UserModel? user;
  const AdminJobScreen({
    super.key,
    required this.tasksData,
    required this.user,
  });

  @override
  State<AdminJobScreen> createState() => _AdminJobScreenState();
}

class _AdminJobScreenState extends State<AdminJobScreen> {
  final UserDataServices _userDataServices = UserDataServices();
  UserModel? userJob;
  bool isTaskAccepted = false;

  @override
  void initState() {
    super.initState();
    getUserJob();
  }

  Future<void> getUserJob() async {
    try {
      userJob = await _userDataServices.getUserById(widget.tasksData.uidUser);

      setState(() {});
    } catch (e) {
      Utility().logger.e(e);
    }
  }

  Future<void> downloadFile(String fileURL) async {
    final Uri url = Uri.parse(fileURL); // แปลง String เป็น Uri

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      print('❌ ไม่สามารถเปิดลิงก์ได้: $fileURL');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Utility().logger.e(widget.tasksData.uidUser);

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text('รายละเอียดงาน'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: backgroundLight,
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ข้อมูลงาน
                      Row(
                        children: [
                          Image.network(
                            widget.tasksData.image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.tasksData.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: backgroundText,
                                ),
                              ),
                              Row(
                                children: const [
                                  Icon(
                                    Icons.access_time,
                                    color: backgroundText,
                                  ),
                                  Text(
                                    'Just now',
                                    style: TextStyle(color: backgroundText),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Divider(height: 20, thickness: 2, color: Colors.white),
                      // รายละเอียดงาน
                      Text(
                        widget.tasksData.description,
                        style: TextStyle(color: backgroundText),
                      ),
                      const SizedBox(height: 20),
                      userJob == null
                          ? Text(
                            "ยังไม่มีผู้รับงาน",
                            style: TextStyle(color: backgroundText),
                          )
                          : Text(
                            'ผู้รับงาน: ${userJob?.firstname} ${userJob?.lastname}',
                            style: TextStyle(
                              color: backgroundText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                      // fileName
                      if (widget.tasksData.fileName != null &&
                          widget.tasksData.fileName!.isNotEmpty) ...[
                        TextButton(
                          onPressed: () {
                            downloadFile(widget.tasksData.fileName!);
                          },
                          child: Text(
                            "ดาวน์โหลดไฟล์",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],

                      Text(
                        'สถานะงาน: ${widget.tasksData.taskStatus}',
                        style: TextStyle(color: backgroundText),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.tasksData.taskStatus == 'รอรับงาน') ...[
              ElevatedButton(
                onPressed: () {
                  print('กดปุ่มแก้ไขงาน');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return EditScreen(tasksData: widget.tasksData);
                      },
                    ),
                  );
                },
                child: Text('แก้ไขงาน'),
              ),
            ],
            if (widget.tasksData.taskStatus == 'ส่งงานสำเร็จ') ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return AdminSubmitWork(
                          tasksData: widget.tasksData,
                          user: userJob!,
                        );
                      },
                    ),
                  );
                },
                child: Text('ประเมิน'),
              ),
            ],

            // การประเมินงาน
            if (widget.tasksData.taskStatus == 'ผ่านการประเมิน') ...[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRatingRow('คุณภาพงาน', widget.tasksData.quality),
                    _buildRatingRow('มารยาท', widget.tasksData.manners),
                    _buildRatingRow('เวลา', widget.tasksData.time),
                    const SizedBox(height: 20),

                    // ข้อเสนอแนะ
                    Text(
                      "ข้อเสนอแนะ",
                      style: TextStyle(fontSize: 18.0, color: primaryText),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: backgroundLight,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        '${widget.tasksData.description}',
                        style: TextStyle(color: backgroundText),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างรูปดาว
  Widget _buildRatingRow(String title, double rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$title:', style: TextStyle(color: primaryText, fontSize: 18.0)),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                Icons.star,
                color: index < rating ? Colors.amber : Colors.grey,
              );
            }),
          ),
        ],
      ),
    );
  }
}
