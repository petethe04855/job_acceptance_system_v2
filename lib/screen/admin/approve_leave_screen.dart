import 'package:flutter/material.dart';
import 'package:flutter_application_3/models/leave_mode.dart';
import 'package:flutter_application_3/services/leave_services.dart';
import 'package:flutter_application_3/themes/colors.dart';
import 'package:flutter_application_3/utils/utility.dart';

class ApproveLeaveScreen extends StatefulWidget {
  const ApproveLeaveScreen({super.key});

  @override
  State<ApproveLeaveScreen> createState() => _ApproveLeaveScreenState();
}

class _ApproveLeaveScreenState extends State<ApproveLeaveScreen> {
  LeaveServices _leaveServices = LeaveServices();
  Utility _utility = Utility();
  List<LeaveModel> _leaves = [];

  @override
  void initState() {
    super.initState();
    _loadLeaves();
  }

  Future<void> _loadLeaves() async {
    try {
      var fetchedLeaves = await _leaveServices.getLeavesByStatus();
      setState(() {
        _leaves = fetchedLeaves;
        _utility.logger.d(_leaves.length);
      });
    } catch (e) {
      _utility.logger.e('Error loading leaves: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load leaves')));
    }
  }

  Future<void> _approveLeave(String userId) async {
    try {
      await _leaveServices.updateLeaveStatusByUid(userId);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Leave approved successfully')));
      _loadLeaves(); // Reload the list to reflect the changes
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to approve leave')));
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
