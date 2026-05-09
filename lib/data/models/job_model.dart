class Job {
  final String id;
  final String title;
  final String companyName;
  final String description;
  final List<String> requirements;
  final List<String> friendlyFeatures;
  final String salaryRange;
  final String location;
  final DateTime createdAt;

  Job({
    required this.id,
    required this.title,
    required this.companyName,
    required this.description,
    required this.requirements,
    required this.friendlyFeatures,
    required this.salaryRange,
    required this.location,
    required this.createdAt,
  });

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'İsimsiz İlan',
      companyName: map['company_name']?.toString() ?? 'Bilinmeyen Şirket',
      description: map['description']?.toString() ?? 'Açıklama belirtilmemiş.',
      requirements: (map['requirements'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      friendlyFeatures: (map['disability_friendly_features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      salaryRange: map['salary_range']?.toString() ?? 'Belirtilmedi',
      location: map['location']?.toString() ?? 'Konum yok',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }
}
