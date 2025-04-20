class LeaveModel {
  String userId;
  String leaveType;
  String status;
  String reason;
  DateTime date;

  LeaveModel({
    required this.userId,
    required this.leaveType,
    required this.status,
    required this.reason,
    required this.date,
  });
}
