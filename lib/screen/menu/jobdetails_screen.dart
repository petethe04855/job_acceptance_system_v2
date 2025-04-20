// ignore_for_file: prefer_const_constructors

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/components/custom_textfield.dart';
import 'package:flutter_application_3/models/tasks_model.dart';
import 'package:flutter_application_3/models/user_model.dart';
import 'package:flutter_application_3/services/task_services.dart';
import 'package:flutter_application_3/themes/colors.dart';
import 'package:flutter_application_3/utils/utility.dart';
import 'package:url_launcher/url_launcher.dart';

class JobdetailScreen extends StatefulWidget {
  final TasksModel tasksData;
  final UserModel? user;

  const JobdetailScreen({
    super.key,
    required this.tasksData,
    required this.user,
  });

  @override
  State<JobdetailScreen> createState() => _JobdetailScreenState();
}

class _JobdetailScreenState extends State<JobdetailScreen> {
  final TaskServices _taskServices = TaskServices();
  bool isTaskAccepted = false;

  TextEditingController detailsController = TextEditingController();
  FilePickerResult? fileNameUploaded;

  @override
  void initState() {
    super.initState();
    isTaskAccepted = widget.tasksData.taskStatus == 'รอส่งงาน';
  }

  Future<void> submitWorkTaskStatusTest() async {
    try {
      // 📌 เช็คว่าได้เลือกไฟล์และกรอกข้อมูลครบถ้วนหรือไม่
      if (fileNameUploaded != null) {
        // 📌 อัปเดตสถานะงานก่อน
        await _taskServices.updateTaskStatusTest(
          widget.tasksData.taskId,
          'ส่งงานสำเร็จ',
          widget.user!.uid,
          fileNameUploaded, // ส่งชื่อไฟล์
        );

        // 📌 หลังจากอัปเดตสถานะงานเสร็จแล้วให้ทำการอัปโหลดไฟล์
        String? fileURL = await _taskServices.uploadFileTest(
          fileNameUploaded!.files.single.path!,
        );

        if (fileURL != null) {
          // 📌 เมื่ออัปโหลดไฟล์เสร็จแล้ว ให้บันทึก URL ของไฟล์ใน Firestore
          await _taskServices.updateTaskFileURL(
            widget.tasksData.taskId,
            'ส่งงานสำเร็จ',
            widget.user!.uid,
            fileURL,
          );

          print('✅ Task status and file uploaded successfully');
        } else {
          print('❌ Failed to upload file');
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('กรุณาแนบไฟล์')));
        return;
      }
      Navigator.pop(context, true); // ✅ ปิดหน้าหลังจากสำเร็จ
    } catch (e) {
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update task status or upload file.'),
        ),
      );
    }
  }

  Future<void> updateTaskStatus() async {
    try {
      String newStatus = isTaskAccepted ? 'ยกเลิก' : 'รอส่งงาน';
      await _taskServices.updateTaskStatus(
        widget.tasksData.taskId,
        newStatus,
        widget.user!.uid,
      );

      setState(() {
        isTaskAccepted = !isTaskAccepted;
      });

      Navigator.pop(context, true); // `true` indicates that a change was made
    } catch (e) {
      print('Failed to update task status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update task status.')),
      );
    }
  }

  Future<void> submitWorkTaskStatus() async {
    try {
      await _taskServices.updateTaskStatus(
        widget.tasksData.taskId,
        'ส่งงานสำเร็จ',
        widget.user!.uid,
      );

      Navigator.pop(context, true); // `true` indicates that a change was made
    } catch (e) {
      print('Failed to update task status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update task status.')),
      );
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
    Utility().logger.e(widget.tasksData.uidUser);
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text('รายละเอียดงาน'),
        backgroundColor: primary,
        foregroundColor: primaryText,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: backgroundLight,
                borderRadius: BorderRadius.all(Radius.circular(25)),
              ),
              child: Container(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              15,
                            ), // Adjust the radius as needed
                          ),
                          child: Image.network(
                            widget.tasksData.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.tasksData.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: backgroundText,
                              ),
                            ),
                            Row(
                              children: const [
                                Icon(Icons.access_time, color: backgroundText),
                                SizedBox(width: 5),
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
                    const SizedBox(height: 10),
                    const Divider(
                      height: 20,
                      thickness: 2,
                      indent: 5,
                      endIndent: 0,
                      color: divider,
                    ),
                    Text(
                      widget.tasksData.description,
                      style: const TextStyle(color: backgroundText),
                    ),
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
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Container(
          //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
          //   child: customTextFormFieldDetails(
          //     controller: detailsController,
          //     hintText: 'รายละเอียด',
          //     maxLines: 5,
          //     prefixIcon: null,
          //     textStyleColor: primaryText,
          //     onTap: () {},
          //   ),
          // ),
          const SizedBox(height: 10),
          widget.tasksData.taskStatus == 'รอส่งงาน'
              ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: GestureDetector(
                  onTap: () async {
                    fileNameUploaded = await FilePicker.platform.pickFiles(
                      allowMultiple: false,
                      type: FileType.custom,
                      allowedExtensions: ['jpg', 'pdf', 'docx'],
                    );
                    setState(() {}); // 📌 อัปเดต UI หลังจากเลือกไฟล์
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: const BoxDecoration(
                      color: backgroundLight,
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_file, color: secondary),
                        Text(
                          fileNameUploaded?.files.single.name ??
                              'แนบไฟล์', // 📌 แสดงชื่อไฟล์ที่เลือก
                          style: TextStyle(color: primaryText),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : const SizedBox(),

          const SizedBox(height: 10),

          // เงื่อนไขในการแสดงปุ่ม
          if (widget.tasksData.taskStatus != 'ยกเลิก' &&
              widget.tasksData.taskStatus != 'ส่งไม่สำเร็จ' &&
              widget.tasksData.taskStatus != 'ผ่านการประเมิน')
            Column(
              children: [
                if (widget.tasksData.taskStatus == 'รอรับงาน') ...[
                  ElevatedButton(
                    onPressed: updateTaskStatus,
                    style: ElevatedButton.styleFrom(backgroundColor: secondary),
                    child: const Text(
                      'รับงาน',
                      style: TextStyle(color: primaryText),
                    ),
                  ),
                ],
                if (widget.tasksData.taskStatus == 'รอส่งงาน') ...[
                  ElevatedButton(
                    onPressed: updateTaskStatus,
                    style: ElevatedButton.styleFrom(backgroundColor: secondary),
                    child: const Text(
                      'ยกเลิกงาน',
                      style: TextStyle(color: primaryText),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: submitWorkTaskStatusTest,
                    style: ElevatedButton.styleFrom(backgroundColor: secondary),
                    child: const Text(
                      'ส่งงานสำเร็จ',
                      style: TextStyle(color: primaryText),
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}
