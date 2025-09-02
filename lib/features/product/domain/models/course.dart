class Course {
  Course({
    this.id,
    required this.name,
    required this.nrc,
    required this.teacher,
    required this.category,
    this.enrolledUsers = const [],
    this.maxStudents = 30,
  });

  String? id;
  String name;
  int nrc;
  String teacher;
  String category;
  List<String> enrolledUsers;
  int maxStudents;

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json["_id"],
    name: json["name"] ?? "---",
    nrc: json["nrc"] ?? 0,
    teacher: json["teacher"] ?? "---",
    category: json["category"] ?? "General",
    enrolledUsers: List<String>.from(json["enrolledUsers"] ?? []),
    maxStudents: json["maxStudents"] ?? 30,
  );

  Map<String, dynamic> toJson() => {
    "_id": id ?? "0",
    "name": name,
    "nrc": nrc,
    "teacher": teacher,
    "category": category,
    "enrolledUsers": enrolledUsers,
    "maxStudents": maxStudents,
  };

  Map<String, dynamic> toJsonNoId() => {
    "name": name,
    "nrc": nrc,
    "teacher": teacher,
    "category": category,
    "enrolledUsers": enrolledUsers,
    "maxStudents": maxStudents,
  };

  int get enrolledCount => enrolledUsers.length;
  bool get hasAvailableSpots => enrolledCount < maxStudents;

  @override
  String toString() {
    return 'Course{id: $id, name: $name, nrc: $nrc, teacher: $teacher, enrolled: $enrolledCount/$maxStudents}';
  }
}
