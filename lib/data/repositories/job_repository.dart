import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job_model.dart';
import 'package:flutter/foundation.dart';

class JobRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Job>> getJobs() async {
    try {
      final response = await _client
          .from('jobs')
          .select()
          .order('created_at', ascending: false);
      
      final List<dynamic> data = response as List<dynamic>;
      return data.map((job) => Job.fromMap(job as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('CRITICAL JobRepository Error: $e');
      // Hatayı fırlatıyoruz ki ekranda kalsın
      throw Exception('Veritabanı Hatası (İşler): $e');
    }
  }

  Future<List<Job>> searchJobs(String query) async {
    try {
      final response = await _client
          .from('jobs')
          .select()
          .ilike('title', '%$query%')
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((job) => Job.fromMap(job as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('CRITICAL JobRepository Search Error: $e');
      throw Exception('Arama Hatası: $e');
    }
  }
}
