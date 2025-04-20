// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:flutter_application_3/app_router.dart';
import 'package:flutter_application_3/models/tasks_model.dart';
import 'package:flutter_application_3/models/user_model.dart';
import 'package:flutter_application_3/screen/menu/check_screen.dart';
import 'package:flutter_application_3/screen/menu/history_received_screen.dart';
import 'package:flutter_application_3/screen/menu/jobdetails_screen.dart';
import 'package:flutter_application_3/services/firbase_auth_services.dart';
import 'package:flutter_application_3/services/task_services.dart';
import 'package:flutter_application_3/themes/colors.dart';
import 'package:flutter_application_3/utils/utility.dart';

var refreshKey = GlobalKey<RefreshIndicatorState>();

class MeunScreen extends StatefulWidget {
  const MeunScreen({super.key});

  @override
  State<MeunScreen> createState() => _MeunScreenState();
}

class _MeunScreenState extends State<MeunScreen> {
  final FirebaseAuthService _userService = FirebaseAuthService();
  final TaskServices _taskServices = TaskServices();
  final Utility _utility = Utility();
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  List<TasksModel> _tasks = [];
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTasks();
  }

  Future<void> _loadUserData() async {
    try {
      UserModel? user = await _userService.getUser();
      if (user != null) {
        setState(() {
          _user = user;
        });
      }
    } catch (e) {
      _utility.logger.e('Error loading user data: $e');
    }
  }

  Future<void> _loadTasks() async {
    try {
      var fetchedTasks = await _taskServices.getTasks();
      setState(() {
        _tasks = fetchedTasks;
        _utility.logger.d("งาน" + _tasks.length.toString());
      });
    } catch (e) {
      _utility.logger.e('Error loading tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<TasksModel> pendingTasks =
        _tasks.where((task) => task.taskStatus == 'รอส่งงาน').toList();

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text('เพิ่มงาน'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      drawer: _buildDrawer(),
      body: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _loadTasks,
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_tasks.any(
                (task) =>
                    task.uidUser == _user?.uid && task.taskStatus == 'รอส่งงาน',
              ))
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Card(
                    color: Colors.white,
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'งานที่รับอยู่ปัจจุบัน',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          SizedBox(
                            height: 200, // กำหนดความสูงให้เหมาะสม
                            child: ListView.builder(
                              itemCount:
                                  _tasks
                                      .where(
                                        (task) =>
                                            task.uidUser == _user!.uid &&
                                            task.taskStatus == 'รอส่งงาน',
                                      )
                                      .length,
                              itemBuilder: (context, index) {
                                var taskList =
                                    _tasks
                                        .where(
                                          (task) =>
                                              task.uidUser == _user!.uid &&
                                              task.taskStatus == 'รอส่งงาน',
                                        )
                                        .toList();
                                var task = taskList[index];

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6.0,
                                    horizontal: 8.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: backgroundLight,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        task.image,
                                        width: 55,
                                        height: 55,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                                  Icons.image_not_supported,
                                                  size: 55,
                                                  color: Colors.grey.shade400,
                                                ),
                                      ),
                                    ),
                                    title: Text(
                                      task.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: backgroundDark,
                                      ),
                                    ),
                                    subtitle: Text(
                                      task.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: primaryText,
                                        fontSize: 14,
                                      ),
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      color: secondary,
                                      size: 18,
                                    ),
                                    onTap: () async {
                                      bool? isUpdated = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => JobdetailScreen(
                                                tasksData: task,
                                                user: _user,
                                              ),
                                        ),
                                      );
                                      if (isUpdated == true) {
                                        _loadTasks();
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Expanded(
                  flex: pendingTasks.isNotEmpty ? 8 : 9,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      TasksModel task = _tasks[index];
                      return task.taskStatus == 'รอรับงาน'
                          ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: GestureDetector(
                              onTap: () async {
                                bool? isUpdated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => JobdetailScreen(
                                          tasksData: task,
                                          user: _user,
                                        ),
                                  ),
                                );
                                if (isUpdated == true) {
                                  _loadTasks();
                                }
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: backgroundLight,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: primaryText,
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                          child: Image.network(
                                            task.image,
                                            fit:
                                                BoxFit
                                                    .cover, // ทำให้รูปภาพเต็มกรอบและรักษาสัดส่วน
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: primaryText,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            task.description,
                                            style: const TextStyle(
                                              color: primaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          : Container();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (_user != null) // ตรวจสอบว่า _user ไม่เป็น null
            DrawerHeader(
              decoration: const BoxDecoration(color: backgroundDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _user!.image == ''
                      ? const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: backgroundDark,
                        ),
                      )
                      : CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(_user!.image),
                        backgroundColor: Colors.transparent,
                      ),
                  const SizedBox(height: 10),
                  Text(
                    'ชื่อผู้ใช้: ${_user!.firstname} ${_user!.lastname}',
                    style: const TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                ],
              ),
            )
          else
            const DrawerHeader(
              decoration: BoxDecoration(color: backgroundDark),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ListTile(
            title: const Text('ประวัติการรับงาน'),
            onTap: () {
              if (_user != null) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HistoryReceivedScreen(user: _user!),
                  ),
                );
              }
            },
          ),
          ListTile(
            title: const Text('ตอกบัตร'),
            onTap: () {
              if (_user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return CheckScreen(uid: _user!.uid);
                    },
                  ),
                );
              }
            },
          ),
          ListTile(
            title: const Text('ลางาน'),
            onTap: () {
              Navigator.pushNamed(context, AppRouter.leave);
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
}
