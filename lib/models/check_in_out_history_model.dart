class CheckInOutHistoryModel {
  final String userId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String date;
  final double latitude; // เพิ่ม latitude
  final double longitude; // เพิ่ม longitude
  // final DateTime date;

  CheckInOutHistoryModel({
    required this.userId,
    required this.checkInTime,
    required this.checkOutTime,
    required this.date,
    required this.latitude, // กำหนดค่า latitude
    required this.longitude, // กำหนดค่า longitude
  });
}
