import 'package:flutter/material.dart';
import 'package:flutter_application_3/components/custom_textfield.dart';
import 'package:flutter_application_3/components/star_rating_widget.dart';
import 'package:flutter_application_3/models/tasks_model.dart';
import 'package:flutter_application_3/models/user_model.dart';
import 'package:flutter_application_3/services/task_services.dart';
import 'package:flutter_application_3/themes/colors.dart';

class AdminSubmitWork extends StatefulWidget {
  final TasksModel tasksData;
  final UserModel user;
  const AdminSubmitWork({
    required this.tasksData,
    required this.user,
    super.key,
  });

  @override
  State<AdminSubmitWork> createState() => _AdminSubmitWorkState();
}

class _AdminSubmitWorkState extends State<AdminSubmitWork> {
  final TaskServices _taskServices = TaskServices();

  final _detailsController = TextEditingController();
  double quality = 3.0;
  double manners = 3.0;
  double time = 3.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text('ส่งงาน'),
        backgroundColor: primary,
        foregroundColor: primaryText,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRatingCard(
              'คุณภาพงาน',
              quality,
              (val) => setState(() => quality = val),
            ),
            SizedBox(height: 20),
            _buildRatingCard(
              'มารยาท',
              manners,
              (val) => setState(() => manners = val),
            ),
            SizedBox(height: 20),
            _buildRatingCard('เวลา', time, (val) => setState(() => time = val)),
            SizedBox(height: 20),
            Text(
              "ขอเสนอแนะ",
              style: TextStyle(fontSize: 20.0, color: primaryText),
            ),
            SizedBox(height: 10),
            customTextFormFieldDetails(
              controller: _detailsController,
              maxLines: 5,
              hintText: 'รายละเอียดงาน',
              prefixIcon: null,
              textStyleColor: backgroundText,
              onTap: () {},
            ),
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondary,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  onPressed: () {
                    _taskServices.upTaskSubmit(
                      widget.tasksData.taskId,
                      quality,
                      manners,
                      time,
                      _detailsController.text,
                    );
                    Navigator.pop(context);
                  },
                  child: Text(
                    "ส่งประเมิน",
                    style: TextStyle(fontSize: 18.0, color: primaryText),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard(
    String title,
    double rating,
    Function(double) onRatingChanged,
  ) {
    return Card(
      color: backgroundLight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$title: $rating',
              style: TextStyle(fontSize: 20.0, color: primaryText),
            ),
            SizedBox(height: 10),
            StarRating(
              rating: rating,
              onRatingChanged: onRatingChanged,
              color: Colors.amber,
            ),
          ],
        ),
      ),
    );
  }
}
