import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'device_detail_page.dart';

class DeviceSupportPage extends StatefulWidget {
  const DeviceSupportPage({super.key});

  @override
  State<DeviceSupportPage> createState() => _DeviceSupportPageState();
}

class _DeviceSupportPageState extends State<DeviceSupportPage> {
  final _supabase = Supabase.instance.client;
  Future<List<dynamic>>? _devicesFuture;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  void _loadDevices() {
    setState(() {
      _devicesFuture = _supabase
          .from('support_devices')
          .select('*, profiles(full_name)')
          .eq('is_active', true)
          .order('created_at', ascending: false);
    });
  }

  void _showAddDeviceSheet() {
    final formKey = GlobalKey<FormState>();
    String deviceName = '';
    String description = '';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Destek Cihazı İlanı Ekle', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Cihaz Adı (Örn: Akülü Tekerlekli Sandalye)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                        onSaved: (v) => deviceName = v ?? '',
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Detaylar ve Özellikler',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                        onSaved: (v) => description = v ?? '',
                      ),
                      const SizedBox(height: 24),
                      
                      ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  formKey.currentState!.save();
                                  setModalState(() => isSubmitting = true);
                                  
                                  try {
                                    final user = _supabase.auth.currentUser;
                                    if (user == null) return;

                                    await _supabase.from('support_devices').insert({
                                      'publisher_id': user.id,
                                      'name': deviceName,
                                      'description': description,
                                      'is_active': true,
                                    });
                                    if (mounted) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cihaz başarıyla eklendi!'), backgroundColor: Colors.green));
                                      _loadDevices();
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
                                    }
                                  } finally {
                                    if (mounted) setModalState(() => isSubmitting = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.orange),
                        child: isSubmitting 
                            ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: Colors.white), SizedBox(width: 12), Text('Ekleniyor...')]) 
                            : const Text('İLAN OLUŞTUR'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cihaz Destek Sistemi'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _devicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata oluştu:\n${snapshot.error}', textAlign: TextAlign.center));
          }

          final devices = snapshot.data ?? [];
          if (devices.isEmpty) {
            return const Center(
              child: Text(
                'Şu an için desteklenen bir cihaz bulunmuyor.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final item = devices[index];
              final deviceName = item['name']?.toString() ?? 'İsimsiz Cihaz';
              final profile = item['profiles'];
              final publisherName = (profile is Map && profile['full_name'] != null) 
                  ? profile['full_name'].toString() 
                  : 'İsimsiz Kurum';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.devices_other, color: Colors.orange, size: 32),
                  ),
                  title: Text(deviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Bağışçı / Kurum: $publisherName', style: TextStyle(color: Colors.orange.shade800)),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DeviceDetailPage(device: item),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDeviceSheet,
        icon: const Icon(Icons.add),
        label: const Text('Cihaz Ekle'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
