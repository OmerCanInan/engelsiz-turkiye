import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoadReportPage extends StatefulWidget {
  const RoadReportPage({super.key});

  @override
  State<RoadReportPage> createState() => _RoadReportPageState();
}

class _RoadReportPageState extends State<RoadReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 1. Konum İzinlerini Kontrol Et
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Konum izni reddedildi. Lütfen ayarlardan izin verin.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Konum izinleri kalıcı olarak reddedilmiş. Ayarlardan açmalısınız.');
      }

      // 2. Mevcut Konumu Al
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      final String latitude = position.latitude.toString();
      final String longitude = position.longitude.toString();
      
      // 3. Veritabanına Yaz
      final user = Supabase.instance.client.auth.currentUser;
      
      await Supabase.instance.client.from('road_reports').insert({
        'user_id': user?.id,
        'description': _descController.text,
        'latitude': latitude,
        'longitude': longitude,
        'status': 'pending', // Bekliyor, admin çözecek
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bildiriminiz başarıyla alındı ve konumuzla birlikte yetkililere iletildi.'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Geri dön
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yol Hata Bildirimi'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Karşılaştığınız Engeli Bildirin',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bozuk yol, rampa eksikliği, asansör arızası gibi engellilerin hayatını zorlaştıran durumları buradan bildirebilirsiniz. Gönder butonuna bastığınızda mevcut konumunuz otomatik olarak yetkililere iletilecektir.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Şikayet Detayı / Açıklama',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.description),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Lütfen bir açıklama yazın.' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitReport,
                  icon: _isSubmitting ? const SizedBox.shrink() : const Icon(Icons.location_on),
                  label: _isSubmitting 
                    ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: Colors.white), SizedBox(width: 12), Text('Konum Alınıyor ve Gönderiliyor...')])
                    : const Text('Konumumu Al ve Bildirimi Gönder', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
