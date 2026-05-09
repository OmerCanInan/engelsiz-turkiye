import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/course_model.dart';

class CourseRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Course>> getCourses() async {
    final response = await _client
        .from('courses')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List).map((c) => Course.fromMap(c)).toList();
  }
}
