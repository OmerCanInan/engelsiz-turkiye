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
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
      },
    );

    if (response.user != null) {
      // Profil tablosuna ekle - ŞEMAYA TAM UYGUN
      await _client.from('profiles').insert({
        'id': response.user!.id,
        'full_name': fullName,
        'disability_type': 'Belirtilmedi',
        'disability_percentage': 0,
      });
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
