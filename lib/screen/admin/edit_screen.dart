import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_3/components/custom_textfield.dart';
import 'package:flutter_application_3/models/tasks_model.dart';
import 'package:flutter_application_3/services/task_services.dart';
import 'package:flutter_application_3/themes/colors.dart';

class EditScreen extends StatefulWidget {
  final TasksModel tasksData;
  const EditScreen({super.key, required this.tasksData});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final TaskServices _taskServices = TaskServices();
  final addFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _image;
  Future<void> getImage() async {
    final image = await _taskServices.pickImage();
    setState(() {
      _image = image;
    });
  }

  Future<void> addTask() async {
    if (addFormKey.currentState!.validate()) {
      await _taskServices.uploadProduct(
        _image,
        _nameController.text,
        _descriptionController.text,
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    _nameController.text = widget.tasksData.name;
    _descriptionController.text = widget.tasksData.description;

    return Scaffold(
      backgroundColor: primary,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('รายละเอียดงาน'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GestureDetector(
                onTap: getImage,
                child:
                    _image == null
                        ? Image.network(
                          widget.tasksData.image,
                          height: 100,
                          width: 100,
                        )
                        : Image.file(_image!, height: 100, width: 100),
              ),
              SizedBox(height: 10),
              ElevatedButton(onPressed: getImage, child: Text('เลือกรูปภาพ')),
              SizedBox(height: 20),
              customTextField(
                controller: _nameController,
                hintText: 'ชื่องาน',
                prefixIcon: null,
                textStyleColor: backgroundText,
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
              SizedBox(height: 20),
              customTextFormFieldDetails(
                controller: _descriptionController,
                maxLines: 5,
                hintText: 'รายละเอียดงาน',
                prefixIcon: null,
                textStyleColor: backgroundText,
                onTap: () {},
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _taskServices.editTask(
                    widget.tasksData.taskId,
                    _image,
                    _nameController.text,
                    _descriptionController.text,
                  );
                  // ส่งค่ากลับหน้าเดิมเป็น true เพื่อบอกว่าแก้ไขข้อมูลสำเร็จ
                  Navigator.pop(context, true);
                },
                child: Text('บันทึกการแก้ไข'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
