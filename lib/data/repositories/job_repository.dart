import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/job_model.dart';

class JobRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Job>> getJobs() async {
    final response = await _client
        .from('jobs')
        .select()
        .order('created_at', ascending: false);
    
    return (response as List).map((job) => Job.fromMap(job)).toList();
  }

  Future<List<Job>> searchJobs(String query) async {
    final response = await _client
        .from('jobs')
        .select()
        .ilike('title', '%$query%')
        .order('created_at', ascending: false);

    return (response as List).map((job) => Job.fromMap(job)).toList();
  }
}
