class Course {
  final String id;
  final String title;
  final String instructor;
  final String category;
  final String? thumbnailUrl;
  final bool isAccessibleContent;
  final DateTime createdAt;

  Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.category,
    this.thumbnailUrl,
    required this.isAccessibleContent,
    required this.createdAt,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      title: map['title'],
      instructor: map['instructor'] ?? 'Anonim',
      category: map['category'] ?? 'Genel',
      thumbnailUrl: map['thumbnail_url'],
      isAccessibleContent: map['is_accessible_content'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
