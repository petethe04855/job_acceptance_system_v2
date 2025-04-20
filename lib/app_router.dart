import 'package:flutter_application_3/screen/admin/add_task_screen.dart';
import 'package:flutter_application_3/screen/admin/meun_admin_screen.dart';
import 'package:flutter_application_3/screen/admin/student_list_screen.dart';
import 'package:flutter_application_3/screen/login/login_screen.dart';
import 'package:flutter_application_3/screen/menu/forgot_password_screen.dart';
import 'package:flutter_application_3/screen/menu/leave_screen.dart';
import 'package:flutter_application_3/screen/menu/meun_screen.dart';
import 'package:flutter_application_3/screen/menu/submit_work_screen.dart';
import 'package:flutter_application_3/screen/register/resgister_screen.dart';

// เส้นทางไปแต่ละหน้า

class AppRouter {
  static const String login = 'login';
  static const String register = 'register';
  static const String success = 'success';
  static const String meun = 'meun';
  static const String meunAdmin = 'meunAdmin';
  static const String addTask = 'addTask';
  // static const String check = 'check';
  static const String leave = 'leave';
  static const String submitwork = 'submitwork';
  static const String studentList = 'studentList';
  static const String forgotPassword = 'forgotPassword';

  static get routes => {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    meun: (context) => const MeunScreen(),
    addTask: (context) => const AddTaskScreen(),
    meunAdmin: (context) => const MeunAdminScreen(),
    // jobdetails: (context) => const JondetailScreen(),
    // check: (context) => const CheckScreen(),
    leave: (context) => const LeaveScreen(),
    submitwork: (context) => const SubmitWorkScreen(),
    studentList: (context) => const StudentListScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
  };
}
