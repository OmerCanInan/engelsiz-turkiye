import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/report_model.dart';

class ReportRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<AccessibilityReport>> getReports() async {
    // PostGIS koordinatlarını çekerken st_asgeojson veya benzeri bir fonksiyon lazım olabilir
    // Ancak Supabase RPC veya direkt select ile geojson formatında veri alabiliriz.
    final response = await _client
        .from('reports')
        .select('*, location');
    
    return (response as List).map((r) => AccessibilityReport.fromMap(r)).toList();
  }

  Future<void> createReport({
    required String title,
    required String description,
    required String category,
    required LatLng location,
    String? imageUrl,
  }) async {
    final userId = _client.auth.currentUser?.id;
    
    // PostGIS için POINT(long lat) formatı
    final pointString = 'POINT(${location.longitude} ${location.latitude})';

    await _client.from('reports').insert({
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'location': pointString,
      'image_url': imageUrl,
    });
  }
}
