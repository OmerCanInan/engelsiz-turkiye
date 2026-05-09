import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';
import 'package:flutter/foundation.dart';

class CourseRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Course>> getCourses() async {
    try {
      final response = await _client
          .from('courses')
          .select()
          .order('created_at', ascending: false);
      
      final List<dynamic> data = response as List<dynamic>;
      return data.map((course) => Course.fromMap(course as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('CRITICAL CourseRepository Error: $e');
      throw Exception('Veritabanı Hatası (Eğitimler): $e');
    }
  }
}
