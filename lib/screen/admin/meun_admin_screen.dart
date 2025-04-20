import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/app_router.dart';
import 'package:flutter_application_3/models/tasks_model.dart';
import 'package:flutter_application_3/models/user_model.dart';
import 'package:flutter_application_3/screen/admin/admin_job_screen.dart';
import 'package:flutter_application_3/screen/admin/approve_leave_screen.dart';
import 'package:flutter_application_3/screen/admin/map/map_screen.dart';
import 'package:flutter_application_3/services/firbase_auth_services.dart';
import 'package:flutter_application_3/services/task_services.dart';
import 'package:flutter_application_3/themes/colors.dart';
import 'package:flutter_application_3/utils/utility.dart';

class MeunAdminScreen extends StatefulWidget {
  const MeunAdminScreen({super.key});

  @override
  State<MeunAdminScreen> createState() => _MeunAdminScreenState();
}

class _MeunAdminScreenState extends State<MeunAdminScreen> {
  final FirebaseAuthService _userService = FirebaseAuthService();
  final TaskServices _taskServices = TaskServices();
  final Utility _utility = Utility();

  List<TasksModel> _tasks = [];
  UserModel? _user;

  String status = 'รอส่งงาน';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      var fetchedTasks = await _taskServices.getTasks();
      setState(() {
        _tasks = fetchedTasks;
        _utility.logger.d(_tasks.map((task) => task.taskStatus).toList());
      });
    } catch (e) {
      _utility.logger.e('Error loading tasks: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load tasks')));
    }
  }

  Future<void> onJobReceived(String status) async {
    try {
      log('Status: $status');
      var fetchedTasks = await _taskServices.getTaskStatus(status);
      setState(() {
        _tasks = fetchedTasks;
        _utility.logger.d(_tasks);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading tasks: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text('เพิ่มงาน'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.addTask);
            },
            icon: const Icon(Icons.add),
          ),
        ],
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadTasks,
        child: Column(
          children: [
            _buildActionButtons(),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => AdminJobScreen(
                                  tasksData: task,
                                  user: _user,
                                ),
                          ),
                        );
                      },
                      child: Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(task.image),
                          ),
                          title: Text(task.name),
                          subtitle: Text(task.name),
                          trailing: Text(task.taskStatus),
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

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: backgroundDark),
            child: Text(
              'เมนูผู้ดูแลระบบ',
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
          ),
          ListTile(
            title: const Text('รายชื่อนักศึกษา'),
            onTap: () {
              Navigator.pushNamed(context, AppRouter.studentList);
            },
          ),
          ListTile(
            title: const Text('เวลาที่นักศึกษาลงเวลา เข้า-ออก'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const ApproveLeaveScreen();
                  },
                ),
              );
            },
          ),
          ListTile(
            title: const Text('ติดตาม'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const MapScreen();
                  },
                ),
              );
            },
          ),
          ListTile(
            trailing: const Icon(Icons.exit_to_app_outlined),
            title: const Text('ออกจากระบบ'),
            onTap: () {
              _userService.signOut();
              Navigator.pushNamed(context, AppRouter.login);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.list, color: Colors.green),
              onPressed: () {
                _loadTasks();
              },
              tooltip: 'งานทั้งหมด',
            ),
          ),
          Flexible(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () {
                onJobReceived('ส่งงานสำเร็จ');
              },
              tooltip: 'ส่งงานสำเร็จ',
            ),
          ),
          Flexible(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.access_time, color: Colors.orange),
              onPressed: () {
                onJobReceived('รอส่งงาน');
              },
              tooltip: 'รอส่งงาน',
            ),
          ),
          Flexible(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () {
                onJobReceived('ยกเลิก');
              },
              tooltip: 'ยกเลิก',
            ),
          ),
          Flexible(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.rate_review, color: Colors.blue),
              onPressed: () {
                onJobReceived('ผ่านการประเมิน');
              },
              tooltip: 'ผ่านการประเมิน',
            ),
          ),
        ],
      ),
    );
  }
}
