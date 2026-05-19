class Catatan {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final String matakuliah;
  final DateTime createdAt;

  Catatan({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.matakuliah,
    required this.createdAt,
  });

  factory Catatan.fromJson(Map<String, dynamic> json) {
    return Catatan(
      id: json['id'] ?? '',
      courseId: json['courseId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      matakuliah: json['courseName'] ?? 'Umum',
      createdAt: json['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'content': content,
      'courseName': matakuliah,
      'timestamp': createdAt.millisecondsSinceEpoch,
    };
  }
}