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
    required this.instructor, // Fallback ile güvenli hale getirildi
    required this.category,
    this.thumbnailUrl,
    required this.isAccessibleContent,
    required this.createdAt,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'İsimsiz Kurs',
      instructor: map['instructor']?.toString() ?? 'Anonim Eğitmen',
      category: map['category']?.toString() ?? 'Genel',
      thumbnailUrl: map['thumbnail_url'],
      isAccessibleContent: map['is_accessible_content'] ?? true,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
    );
  }
}
