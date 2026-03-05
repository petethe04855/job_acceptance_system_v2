import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/custom_textfield.dart';
import 'package:flutter_application_1/themes/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> resetPassword(String email) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // ✅ เช็คอีเมลใน Firestore ก่อนว่ามีในระบบหรือไม่
      final querySnapshot = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (!mounted) return;

      if (querySnapshot.docs.isEmpty) {
        // ไม่พบอีเมลในระบบ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ไม่พบอีเมลนี้ในระบบ กรุณาตรวจสอบอีเมลอีกครั้ง'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // พบอีเมล → ส่ง reset email
      await _auth.sendPasswordResetEmail(email: email.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ส่งอีเมลรีเซ็ตรหัสผ่านเรียบร้อยแล้ว กรุณาตรวจสอบอีเมลของคุณ',
          ),
          backgroundColor: Colors.green,
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg;
      if (e.code == 'user-not-found') {
        msg = 'ไม่พบอีเมลนี้ในระบบ';
      } else if (e.code == 'invalid-email') {
        msg = 'รูปแบบอีเมลไม่ถูกต้อง';
      } else {
        msg = 'เกิดข้อผิดพลาด: ${e.message}';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เกิดข้อผิดพลาด โปรดลองอีกครั้ง'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text('ลืมรหัสผ่าน'),
        backgroundColor: primary,
        foregroundColor: primaryText,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'กรุณากรอกอีเมลของคุณ',
                style: TextStyle(color: secondaryText, fontSize: 16),
              ),
              const SizedBox(height: 20),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => resetPassword(_emailController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'รีเซ็ตรหัสผ่าน',
                          style: TextStyle(color: primaryText, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: divider),
            ],
          ),
        ),
      ),
    );
  }
}
