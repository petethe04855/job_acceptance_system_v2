import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/app_router.dart';
import 'package:flutter_application_3/services/firbase_auth_services.dart';
import 'package:flutter_application_3/themes/colors.dart';
import 'package:flutter_application_3/components/custom_textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthService loginService = FirebaseAuthService();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  bool _isObscure = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void passwordfunction() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  Future<void> login() async {
    if (loginFormKey.currentState!.validate()) {
      try {
        // Log the user in
        await loginService.signInWithEmailAndPassword(
          _emailController.text,
          _passwordController.text,
        );

        // Fetch the user's role from Firestore
        String uid = FirebaseAuth.instance.currentUser!.uid;
        DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('Users').doc(uid).get();

        // Check if the user's role is 'admin' or 'user'
        if (userSnapshot.exists) {
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;
          String role = userData['role'];

          if (role == 'admin') {
            // Navigate to the admin screen
            Navigator.pushNamed(context, AppRouter.meunAdmin);
          } else if (role == 'นักศึกษา') {
            // Navigate to the user screen
            Navigator.pushNamed(context, AppRouter.meun);
          } else {
            // Handle other roles or default
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ไม่พบสิทธิ์การใช้งานที่ถูกต้อง')),
            );
          }
        } else {
          // Handle the case where no role is found
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาดในการดึงข้อมูลสิทธิ์')),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle login errors like wrong-password or user-not-found
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = 'ไม่พบบัญชีนี้';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'รหัสผ่านไม่ถูกต้อง';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'รูปแบบอีเมลไม่ถูกต้อง';
        } else {
          errorMessage = 'เกิดข้อผิดพลาด โปรดลองอีกครั้ง';
        }

        // Show error message using a SnackBar
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      } catch (e) {
        // Handle general errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด โปรดลองอีกครั้ง')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        color: const Color(0xFF1F1F39),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Log in",
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  Image.asset(
                    'assets/images/logo.png', // Path to your image
                    height: 150,
                  ),
                  Container(),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFF2F2F42),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Form(
                    key: loginFormKey,
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Text(
                              "Email",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        customTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          prefixIcon: null,
                          suffixIcon: null,
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "กรุณากรอกอีเมล";
                            } else if (!value.contains("@")) {
                              return "กรุณากรอกอีเมลให้ถูกต้อง";
                            }
                            return null;
                          },
                          onSaved: null,
                          textStyleColor: primaryText,
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Text(
                              "Password",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        customTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: null,
                          suffixIcon: IconButton(
                            color: Colors.white,
                            onPressed: passwordfunction,
                            icon:
                                !_isObscure
                                    ? const Icon(Icons.visibility_off)
                                    : const Icon(Icons.visibility),
                          ),
                          obscureText: !_isObscure,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "กรุณากรอกรหัสผ่าน";
                            } else if (value.length < 6) {
                              return "กรุณากรอกรหัสผ่านอย่างน้อย 6 ตัวอักษร";
                            }
                            return null;
                          },
                          onSaved: null,
                          textStyleColor: primaryText,
                        ),
                        const SizedBox(height: 30),
                        const Divider(
                          color: Color(0xFF858597),
                          height: 2.5,
                          thickness: 1,
                          indent: 0,
                          endIndent: 0,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.forgotPassword,
                                );
                              },
                              child: const Text(
                                "Forget password?",
                                style: TextStyle(color: Color(0xFF858597)),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRouter.register,
                                );
                              },
                              child: const Text(
                                "สมัครสมาชิก",
                                style: TextStyle(color: Color(0xFF858597)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              color: secondary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              height: 55,
                              alignment: Alignment.center,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "เข้าสู่ระบบ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
