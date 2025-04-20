import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/tasks_model.dart';
import 'package:flutter_application_3/models/user_model.dart';
import 'package:flutter_application_3/screen/menu/jobdetails_screen.dart';
import 'package:flutter_application_3/services/task_services.dart';
import 'package:flutter_application_3/themes/colors.dart';
import 'package:flutter_application_3/utils/utility.dart';

class HistoryReceivedScreen extends StatefulWidget {
  final UserModel user;
  const HistoryReceivedScreen({super.key, required this.user});

  @override
  State<HistoryReceivedScreen> createState() => _HistoryReceivedScreenState();
}

class _HistoryReceivedScreenState extends State<HistoryReceivedScreen> {
  final TaskServices _taskServices = TaskServices();
  final Utility _utility = Utility();
  List<TasksModel> pendingTasks = [];
  List<TasksModel> completedTasks = [];
  List<TasksModel> cancelledTasks = [];
  List<TasksModel> failedTasks = [];
  List<TasksModel> reviewedTasks = []; // เพิ่มลิสต์สำหรับงานที่ผ่านการประเมิน

  Future<void> getTasks() async {
    List<TasksModel> tasks = await _taskServices.getTasksByStatus(
      widget.user.uid,
    );

    setState(() {
      pendingTasks =
          tasks.where((task) => task.taskStatus == 'รอส่งงาน').toList();
      completedTasks =
          tasks.where((task) => task.taskStatus == 'ส่งงานสำเร็จ').toList();
      cancelledTasks =
          tasks.where((task) => task.taskStatus == 'ยกเลิก').toList();
      failedTasks =
          tasks.where((task) => task.taskStatus == 'ไม่สำเร็จ').toList();
      reviewedTasks =
          tasks
              .where((task) => task.taskStatus == 'ผ่านการประเมิน')
              .toList(); // กรองงานที่ผ่านการประเมิน
    });
  }

  @override
  void initState() {
    super.initState();
    getTasks();
    _utility.logger.d(pendingTasks);
  }

  Widget _buildTaskList(String title, List<TasksModel> tasks) {
    if (tasks.isEmpty) return Container();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            TasksModel task = tasks[index];
            _utility.logger.d(tasks);
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: const BoxDecoration(
                  color: backgroundLight,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: ListTile(
                  leading: Image.network(
                    task.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    task.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: backgroundText,
                    ),
                  ),
                  subtitle: Text(
                    task.description,
                    style: const TextStyle(color: backgroundText),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Utility().logger.d(task.fileName);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => JobdetailScreen(
                                tasksData: task,
                                user: widget.user,
                              ),
                        ),
                      );
                    },
                    child: const Text("รายละเอียด"),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text('ประวัติการรับงาน'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildTaskList(
              'ผ่านการประเมิน',
              reviewedTasks,
            ), // เพิ่มการแสดงผลงานที่ผ่านการประเมิน
            _buildTaskList('ส่งงานสำเร็จ', completedTasks),
            _buildTaskList('รอส่งงาน', pendingTasks),
            _buildTaskList('ยกเลิก', cancelledTasks),
            _buildTaskList('ไม่สำเร็จ', failedTasks),
          ],
        ),
      ),
    );
  }
}
