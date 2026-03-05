import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/app_router.dart';
import 'package:flutter_application_1/components/custom_textfield.dart';
import 'package:flutter_application_1/services/firbase_auth_services.dart';
import 'package:flutter_application_1/themes/colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final registerKey = GlobalKey<FormState>();

  bool _isObscure = false;
  bool _isObscure2 = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();

  File? _imageFile; // To hold the selected image

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Show Snackbar for feedback
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  passwordfunction() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  passwordConfirmfunction() {
    setState(() {
      _isObscure2 = !_isObscure2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: primary,
        title: Row(
          children: [
            const Text("Register", style: TextStyle(color: Colors.white)),
            Image.asset('assets/images/logo.png', height: 150),
          ],
        ),
      ),
      body: Container(
        color: const Color(0xFF1F1F39),
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Container(
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
                    key: registerKey,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _pickImage, // Tap to pick image
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey,
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : null,
                            child: _imageFile == null
                                ? const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 50,
                                  )
                                : null,
                          ),
                        ),
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
                            } else if (!RegExp(
                              r'^[\w\.\+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$',
                            ).hasMatch(value)) {
                              return "รูปแบบอีเมลไม่ถูกต้อง เช่น example@email.com";
                            }
                            return null;
                          },
                          onSaved: null,
                          textStyleColor: backgroundText,
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Text("ชื่อ", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        customTextField(
                          controller: _firstnameController,
                          hintText: 'ชื่อ',
                          prefixIcon: null,
                          suffixIcon: null,
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "กรุณากรอกชื่อ";
                            }
                            return null;
                          },
                          onSaved: null,
                          textStyleColor: backgroundText,
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Text(
                              "นามสกุล",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        customTextField(
                          controller: _lastnameController,
                          hintText: 'นามสกุล',
                          prefixIcon: null,
                          suffixIcon: null,
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "กรุณากรอกนามสกุล";
                            }
                            return null;
                          },
                          onSaved: null,
                          textStyleColor: backgroundText,
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
                            icon: !_isObscure
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                          ),
                          obscureText: !_isObscure,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "กรุณากรอกรหัสผ่าน";
                            } else if (value.length < 6) {
                              return "กรุณากรอกรหัสผ่านอย่างน้อย 6 ตัวอักษร";
                            } else if (!RegExp(r'[a-z]').hasMatch(value)) {
                              return "รหัสผ่านต้องมีตัวพิมพ์เล็กอย่างน้อย 1 ตัว (a-z)";
                            } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                              return "รหัสผ่านต้องมีตัวพิมพ์ใหญ่อย่างน้อย 1 ตัว (A-Z)";
                            } else if (!RegExp(r'[0-9]').hasMatch(value)) {
                              return "รหัสผ่านต้องมีตัวเลขอย่างน้อย 1 ตัว";
                            }
                            return null;
                          },
                          onSaved: null,
                          textStyleColor: backgroundText,
                        ),
                        const SizedBox(height: 20),
                        const Row(
                          children: [
                            Text(
                              "Confirm Password",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        customTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Password',
                          prefixIcon: null,
                          suffixIcon: IconButton(
                            color: Colors.white,
                            onPressed: passwordConfirmfunction,
                            icon: !_isObscure2
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                          ),
                          obscureText: !_isObscure2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "กรุณากรอกรหัสผ่าน";
                            } else if (value != _passwordController.text) {
                              return "รหัสผ่านไม่ตรงกัน";
                            }
                            return null;
                          },
                          onSaved: null,
                          textStyleColor: backgroundText,
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
                        ElevatedButton(
                          onPressed: () async {
                            if (registerKey.currentState!.validate()) {
                              // Logic to upload the selected image and then create the user
                              if (_imageFile != null) {
                                try {
                                  await _auth.sigUpWithEmailAndPassWord(
                                    _emailController.text,
                                    _imageFile,
                                    _passwordController.text,
                                    _confirmPasswordController.text,
                                    _firstnameController.text,
                                    _lastnameController.text,
                                  );
                                  Navigator.pushNamed(context, AppRouter.login);
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'email-already-in-use') {
                                    _showSnackbar(
                                      'อีเมลนี้ถูกใช้งานแล้ว กรุณาใช้อีเมลอื่น',
                                    );
                                  } else {
                                    _showSnackbar(
                                      'เกิดข้อผิดพลาด: ${e.message}',
                                    );
                                  }
                                } catch (e) {
                                  _showSnackbar('เกิดข้อผิดพลาดที่ไม่คาดคิด');
                                }
                              } else {
                                // Show error message
                                _showSnackbar('กรุณาเลือกรูปโปรไฟล์');
                              }
                            }
                          },
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
                              child: const Text(
                                "สมัครสมาชิก",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
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
