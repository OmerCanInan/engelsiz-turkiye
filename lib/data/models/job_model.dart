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
      id: map['id'],
      title: map['title'],
      companyName: map['company_name'],
      description: map['description'] ?? '',
      requirements: List<String>.from(map['requirements'] ?? []),
      friendlyFeatures: List<String>.from(map['disability_friendly_features'] ?? []),
      salaryRange: map['salary_range'] ?? '',
      location: map['location'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
