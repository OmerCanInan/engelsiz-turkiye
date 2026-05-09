import 'package:flutter/material.dart';
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
  String _selectedDisability = 'ortopedik';
  double _percentage = 40;

  final List<Map<String, String>> _disabilityTypes = [
    {'id': 'ortopedik', 'label': 'Ortopedik'},
    {'id': 'gorme', 'label': 'Görme'},
    {'id': 'isitme', 'label': 'İşitme'},
    {'id': 'zihinsel', 'label': 'Zihinsel'},
    {'id': 'diger', 'label': 'Diğer'},
  ];

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      try {
        await AuthService().signUp(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _nameController.text,
          disabilityType: _selectedDisability,
          disabilityPercentage: _percentage.toInt(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kayıt başarılı! Giriş yapabilirsiniz.')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Hesap Oluştur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Size daha iyi hizmet verebilmemiz için bilgilerinizi eksiksiz doldurun.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v!.isEmpty ? 'Gerekli' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta Adresi',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) => v!.isEmpty ? 'Gerekli' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Şifre',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (v) => v!.length < 6 ? 'En az 6 karakter' : null,
              ),
              const SizedBox(height: 32),
              const Text(
                'Engel Durumu',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedDisability,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.accessibility)),
                items: _disabilityTypes.map((type) {
                  return DropdownMenuItem(
                    value: type['id'],
                    child: Text(type['label']!),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedDisability = v!),
              ),
              const SizedBox(height: 24),
              Text(
                'Engel Oranı: %${_percentage.toInt()}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Slider(
                value: _percentage,
                min: 40,
                max: 100,
                divisions: 12,
                label: '%${_percentage.toInt()}',
                onChanged: (v) => setState(() => _percentage = v),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _handleRegister,
                child: const Text('KAYIT OL'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
