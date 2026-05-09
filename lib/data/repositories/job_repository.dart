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

  Future<void> createJob({
    required String title,
    required String companyName,
    required String description,
    required String location,
    required String salaryRange,
    required List<String> friendlyFeatures,
    required List<String> requirements,
  }) async {
    try {
      await _client.from('jobs').insert({
        'company_id': _client.auth.currentUser!.id,
        'title': title,
        'company_name': companyName,
        'description': description,
        'location': location,
        'salary_range': salaryRange,
        'disability_friendly_features': friendlyFeatures,
        'requirements': requirements,
      });
    } catch (e) {
      debugPrint('İlan Oluşturma Hatası: $e');
      throw Exception('İlan oluşturulamadı: $e');
    }
  }
}
