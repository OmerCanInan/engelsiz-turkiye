import 'package:google_maps_flutter/google_maps_flutter.dart';

class AccessibilityReport {
  final String id;
  final String title;
  final String description;
  final String category;
  final LatLng location;
  final String? imageUrl;
  final String status;
  final DateTime createdAt;

  AccessibilityReport({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.imageUrl,
    required this.status,
    required this.createdAt,
  });

  factory AccessibilityReport.fromMap(Map<String, dynamic> map) {
    // PostGIS Point verisinden (geojson formatında gelebilir) LatLng ayıklama
    final List coordinates = map['location']['coordinates'];
    return AccessibilityReport(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      category: map['category'],
      location: LatLng(coordinates[1], coordinates[0]), // PostGIS: [lon, lat]
      imageUrl: map['image_url'],
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
