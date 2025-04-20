import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/user_model.dart';
import 'package:flutter_application_3/screen/admin/student_detail_screen.dart';
import 'package:flutter_application_3/services/user_data_services.dart';
import 'package:flutter_application_3/themes/colors.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final UserDataServices _userDataServices = UserDataServices();

  List<UserModel> studentList = [];

  @override
  void initState() {
    super.initState();
    getStudentList();
  }

  Future<void> getStudentList() async {
    try {
      var fetchedStudents = await _userDataServices.getUserData();
      setState(() {
        studentList = fetchedStudents;
      });
    } catch (e) {
      print('Error loading student list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text('รายชื่อนักศึกษา'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: studentList.length,
                itemBuilder: (context, index) {
                  var student = studentList[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return StudentDetailsScreen(userDetail: student);
                          },
                        ),
                      );
                    },
                    child: Card(
                      child: ListTile(
                        title: Text('${student.firstname} ${student.lastname}'),
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
}
