import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';

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
    try {
      // PostGIS Point verisi: {"type": "Point", "coordinates": [lon, lat]}
      final locationData = map['location'];
      double lat = 0;
      double lon = 0;

      if (locationData is Map && locationData['coordinates'] is List) {
        final coords = locationData['coordinates'] as List;
        lon = (coords[0] as num).toDouble();
        lat = (coords[1] as num).toDouble();
      }

      return AccessibilityReport(
        id: map['id']?.toString() ?? '',
        title: map['title']?.toString() ?? 'Başlıksız',
        description: map['description']?.toString() ?? '',
        category: map['category']?.toString() ?? 'diger',
        location: LatLng(lat, lon),
        imageUrl: map['image_url'],
        status: map['status'] ?? 'pending',
        createdAt: map['created_at'] != null 
            ? DateTime.parse(map['created_at']) 
            : DateTime.now(),
      );
    } catch (e) {
      debugPrint('AccessibilityReport Parse Error: $e');
      return AccessibilityReport(
        id: '',
        title: 'Hata',
        description: '',
        category: 'diger',
        location: const LatLng(0, 0),
        status: 'error',
        createdAt: DateTime.now(),
      );
    }
  }
}
