// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_application_3/components/custom_textfield.dart';
import 'package:flutter_application_3/themes/colors.dart';
import 'package:flutter_application_3/components/star_rating_widget.dart';

class SubmitWorkScreen extends StatefulWidget {
  const SubmitWorkScreen({super.key});

  @override
  State<SubmitWorkScreen> createState() => _SubmitWorkScreenState();
}

class _SubmitWorkScreenState extends State<SubmitWorkScreen> {
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
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'คุณภาพงาน: $quality',
                      style: TextStyle(fontSize: 24.0, color: Colors.white),
                    ),
                    StarRating(
                      rating: quality,
                      onRatingChanged: (val) => setState(() => quality = val),
                      color: Colors.amber,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'มารยาท: $manners',
                      style: TextStyle(fontSize: 24.0, color: Colors.white),
                    ),
                    StarRating(
                      rating: manners,
                      onRatingChanged: (val) => setState(() => manners = val),
                      color: Colors.amber,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'เวลา: $time',
                      style: TextStyle(fontSize: 24.0, color: Colors.white),
                    ),
                    StarRating(
                      rating: time,
                      onRatingChanged: (val) => setState(() => time = val),
                      color: Colors.amber,
                    ),
                  ],
                ),
              ),
              Text(
                "ขอเสนอแนะ",
                style: TextStyle(fontSize: 24.0, color: Colors.white),
              ),
              customTextFormFieldDetails(
                controller: _detailsController,
                maxLines: 10,
                hintText: 'รายละเอียดงาน',
                prefixIcon: null,
                textStyleColor: backgroundText,
                onTap: () {},
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: () {}, child: Text("ส่งประเมิน")),
            ],
          ),
        ),
      ),
    );
  }
}
