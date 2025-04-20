import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_3/app_router.dart';
import 'package:flutter_application_3/firebase_options.dart';
import 'package:flutter_application_3/utils/utility.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

var initialRoute;

void main() async {
  Intl.defaultLocale = 'th_TH';
  initializeDateFormatting('th_TH', null);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  var _authUser = FirebaseAuth.instance;

  // กำหนดตัวแปร initialRoute ให้กับ MaterialApp
  await Utility.initSharedPrefs();
  // initialRoute = AppRouter.login;
  if (_authUser.currentUser != null) {
    // User is authenticated, check their role and navigate accordingly
    Map<String, dynamic>? userData =
        await Utility.checkSharedPreferenceRoleUser(_authUser.currentUser!.uid);

    if (userData != null) {
      String userRole = userData['role'];
      if (userRole == 'นักศึกษา') {
        initialRoute = AppRouter.meun;
      } else if (userRole == 'admin') {
        initialRoute =
            AppRouter.meunAdmin; // Assuming there's an admin dashboard route
      }
    } else {
      // If user data is not available, navigate to login
      initialRoute = AppRouter.login;
    }
  } else {
    // User is not authenticated, navigate to login
    initialRoute = AppRouter.login;
  }

  // initialRoute = AppRouter.login;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: AppRouter.routes,
    );
  }
}
