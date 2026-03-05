// ignore_for_file: prefer_const_constructors
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/custom_textfield.dart';
import 'package:flutter_application_1/services/task_services.dart';
import 'package:flutter_application_1/themes/colors.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TaskServices _taskServices = TaskServices();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final addFormKey = GlobalKey<FormState>();

  File? _image;
  Future<void> getImage() async {
    final image = await _taskServices.pickImage();
    setState(() {
      _image = image;
    });
  }

  Future<void> addTask() async {
    if (addFormKey.currentState!.validate()) {
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเลือกรูปภาพสำหรับงาน')),
        );
        return;
      }
      try {
        await _taskServices.uploadProduct(
          _image,
          _nameController.text,
          _descriptionController.text,
        );
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('เพิ่มงานไม่สำเร็จ โปรดลองอีกครั้ง')),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('เพิ่มงาน'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Form(
                key: addFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    GestureDetector(
                      onTap: getImage,
                      child: _image == null
                          ? const Icon(Icons.image, size: 100)
                          : Image.file(_image!, height: 100, width: 100),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: getImage,
                      child: const Text('เลือกรูปภาพ'),
                    ),
                    const SizedBox(height: 20),
                    customTextField(
                      controller: _nameController,
                      hintText: 'ชื่องาน',
                      prefixIcon: null,
                      textStyleColor: primaryText,
                      obscureText: false,
                      suffixIcon: null,
                      onSaved: (p0) {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'กรุณากรอกชื่องาน';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    customTextFormFieldDetails(
                      controller: _descriptionController,
                      maxLines: 5,
                      hintText: 'รายละเอียดงาน',
                      prefixIcon: null,
                      textStyleColor: primaryText,
                      onTap: () {},
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: addTask,
                      child: const Text('เพิ่มงาน'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
