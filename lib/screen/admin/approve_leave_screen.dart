import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/leave_mode.dart';
import 'package:flutter_application_1/services/leave_services.dart';
import 'package:flutter_application_1/themes/colors.dart';
import 'package:flutter_application_1/utils/utility.dart';

class ApproveLeaveScreen extends StatefulWidget {
  const ApproveLeaveScreen({super.key});

  @override
  State<ApproveLeaveScreen> createState() => _ApproveLeaveScreenState();
}

class _ApproveLeaveScreenState extends State<ApproveLeaveScreen> {
  final LeaveServices _leaveServices = LeaveServices();
  final Utility _utility = Utility();
  final List<LeaveModel> _leaves = [];

  @override
  void initState() {
    super.initState();
    _loadLeaves();
  }

  Future<void> _loadLeaves() async {
    try {
      var fetchedLeaves = await _leaveServices.getLeavesByStatus();
      if (!mounted) return;
      setState(() {
        _leaves.clear();
        _leaves.addAll(fetchedLeaves);
        _utility.logger.d(_leaves.length);
      });
    } catch (e) {
      _utility.logger.e('Error loading leaves: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('โหลดข้อมูลการลาไม่สำเร็จ')));
    }
  }

  Future<void> _approveLeave(String userId) async {
    try {
      await _leaveServices.updateLeaveStatusByUid(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อนุมัติการลาเรียบร้อยแล้ว')),
      );
      _loadLeaves();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อนุมัติการลาไม่สำเร็จ โปรดลองอีกครั้ง')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        title: const Text('อนุมัติการลา'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildLeaveList(),
      ),
    );
  }

  Widget _buildLeaveList() {
    return ListView.builder(
      itemCount: _leaves.length,
      itemBuilder: (context, index) {
        var leave = _leaves[index];
        return GestureDetector(
          child: Card(
            child: ListTile(
              title: Text(leave.reason),
              subtitle: Text(leave.date.toString()),
              trailing: Text(leave.status),
              leading: IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  _approveLeave(leave.userId);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
