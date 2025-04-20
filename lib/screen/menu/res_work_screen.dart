import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/tasks_model.dart';
import 'package:flutter_application_3/models/user_model.dart';
import 'package:flutter_application_3/services/task_services.dart';
import 'package:flutter_application_3/themes/colors.dart';

class ResWorkScreen extends StatefulWidget {
  final TasksModel tasksData;
  final UserModel user;
  const ResWorkScreen({super.key, required this.tasksData, required this.user});

  @override
  State<ResWorkScreen> createState() => _ResWorkScreenState();
}

class _ResWorkScreenState extends State<ResWorkScreen> {
  final TaskServices _taskServices = TaskServices();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      await _taskServices.getTasksByUid(widget.user.uid);
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text('รับงาน'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: Container(child: Column(children: [])),
    );
  }
}
