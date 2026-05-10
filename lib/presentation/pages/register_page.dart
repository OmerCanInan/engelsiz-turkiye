import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;
  bool _isCompany = false; // Şirket mi?

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await AuthService().signUp(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _nameController.text,
          phone: _phoneController.text,
          isCompany: _isCompany,
          companyDescription: _isCompany ? _descController.text : null,
        );
        
        if (_isCompany) {
          // Şirket ise onay bekleyeceği için sistemden anında çıkış yaptır.
          await AuthService().signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Şirket kayıt isteğiniz oluşturulmuştur. Onay durumunuz mail ile bildirilecektir.', style: TextStyle(color: Colors.white)), 
                backgroundColor: Colors.green,
                duration: Duration(seconds: 5),
              ),
            );
            Navigator.of(context).pop(); // Sadece login'e at
          }
        } else {
          // Normal kullanıcıysa başarılı mesajı ver ve içeri al
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Kayıt Başarılı! Hoş geldiniz.', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      } on AuthException catch (e) {
        String message = 'Kayıt Hatası: ${e.message}';
        if (e.message.contains('User already registered')) {
          message = 'Bu e-posta zaten kullanımda! Lütfen giriş yapmayı deneyin.';
        } else if (e.message.contains('429')) {
          message = 'Çok fazla istek yapıldı. Lütfen biraz bekleyin.';
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Beklenmeyen hata: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // KLAVYE ÇÖKMESİNİ ÖNLER
      appBar: AppBar(title: const Text('Yeni Hesap Oluştur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Engelsiz Türkiye platformuna hoş geldiniz.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad / Kurum Adı',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v!.isEmpty ? 'Ad soyad veya kurum adı gerekli' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Telefon Numarası (SOS için önemli)',
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (v) => null, // KVKK gereği isteğe bağlı bırakıldı
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta Adresi',
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
                validator: (v) => v!.length < 6 ? 'Şifre en az 6 karakter olmalı' : null,
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text('Kurumsal Hesap (İşveren)'),
                  subtitle: const Text('İş ilanı vermek isteyen şirketler için.'),
                  value: _isCompany,
                  onChanged: (val) {
                    setState(() {
                      _isCompany = val;
                    });
                  },
                ),
              ),
              if (_isCompany) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Kısaca Şirketinizden Bahsedin',
                    prefixIcon: Icon(Icons.business_center_outlined),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => v!.isEmpty ? 'Onay için şirket açıklaması zorunludur' : null,
                ),
              ],
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('KAYIT OL'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
