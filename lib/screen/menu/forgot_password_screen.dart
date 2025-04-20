import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_3/components/custom_textfield.dart';
import 'package:flutter_application_3/themes/colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Password reset email sent')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'กรุณากรอกอีเมลของคุณ',
              style: TextStyle(color: secondaryText, fontSize: 16),
            ),
            SizedBox(height: 20),
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
              textStyleColor: backgroundText,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  resetPassword(_emailController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Reset Password',
                  style: TextStyle(color: primaryText, fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            Divider(color: divider),
          ],
        ),
      ),
    );
  }
}
