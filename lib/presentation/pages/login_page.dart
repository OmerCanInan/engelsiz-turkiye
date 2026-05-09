import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import 'register_page.dart';
import '../../main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await AuthService().signIn(
        _emailController.text,
        _passwordController.text,
      );
      // Başarılı girişte AuthGate otomatik yönlendirir
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Giriş Başarılı! Yönlendiriliyorsunuz...', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
        );
      }
    } on AuthException catch (e) {
      String msg = 'Giriş Hatası: ${e.message}';
      if (e.message.contains('Invalid login credentials')) {
        msg = 'Hatalı e-posta veya şifre girdiniz.';
      } else if (e.message.contains('Email not confirmed')) {
        msg = 'Bu e-posta onay bekliyor. (Şirket onayı süreci olabilir)';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // KLAVYE ÇÖKMESİNİ ÖNLER
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              const Icon(Icons.accessibility_new, size: 80, color: Color(0xFF1A56BE)),
              const SizedBox(height: 16),
              const Text(
                'Erişilebilir Türkiye',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Engelleri Birlikte Aşıyoruz',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (v) => v!.isEmpty || !v.contains('@') ? 'Geçerli bir e-posta girin' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Şifre',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (v) => v!.isEmpty ? 'Şifre boş bırakılamaz' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('GİRİŞ YAP'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => const RegisterPage())
                  );
                },
                child: const Text('Hesabınız yok mu? Kayıt Olun'),
              ),
              const SizedBox(height: 24),
              ValueListenableBuilder<bool>(
                valueListenable: accessibilityModeNotifier,
                builder: (context, value, child) {
                  return SwitchListTile(
                    title: const Text('Görme Engelli Modu (Simülasyon)'),
                    subtitle: const Text('Ekran okuyucu açmadan Talkback arayüzüne geçişi sağlar.'),
                    value: value,
                    activeColor: Colors.blue,
                    onChanged: (bool val) async {
                      accessibilityModeNotifier.value = val;
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool('accessibility_mode', val);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
