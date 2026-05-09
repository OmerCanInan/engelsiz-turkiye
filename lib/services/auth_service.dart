import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Giriş Yap
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Kayıt Ol + Profil Oluştur
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    bool isCompany = false,
    String? companyDescription,
    String? phone,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
      },
    );

    if (response.user != null) {
      // Sadece kesin olan verileri yazarak SQL çökmesini engelliyoruz
      try {
        await _client.from('profiles').insert({
          'id': response.user!.id,
          'full_name': fullName,
          'role': isCompany ? 'company' : 'user',
          'company_description': companyDescription,
          'approval_status': isCompany ? 'pending' : 'approved',
          'phone_number': phone,
        });
      } catch (e) {
        throw AuthException('Profil oluşturulamadı, veritabanı şemasını kontrol edin: $e');
      }
    }

    return response;
  }

  // Çıkış Yap
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Mevcut Kullanıcı
  User? get currentUser => _client.auth.currentUser;
}
