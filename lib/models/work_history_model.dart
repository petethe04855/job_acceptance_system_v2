class WorkHistoryModel {
  final String userId;
  final String checkInTime;
  final String? checkOutTime;
  final DateTime date;

  WorkHistoryModel({
    required this.userId,
    required this.checkInTime,
    required this.checkOutTime,
    required this.date,
  });
}
