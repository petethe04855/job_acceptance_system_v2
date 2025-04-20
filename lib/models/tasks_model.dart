class TasksModel {
  String taskId;
  String name;
  String description;
  String image;
  String taskStatus;
  String uidUser;
  double quality;
  double manners; // ต้องเป็น double
  double time; // ต้องเป็น double
  String suggestion;
  String? fileName;

  TasksModel({
    required this.taskId,
    required this.name,
    required this.description,
    required this.image,
    required this.taskStatus,
    required this.uidUser,
    required this.quality,
    required this.manners,
    required this.time,
    required this.suggestion,
    required this.fileName,
  });
}
