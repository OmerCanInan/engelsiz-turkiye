import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DeviceDetailPage extends StatelessWidget {
  final Map<String, dynamic> device;

  const DeviceDetailPage({super.key, required this.device});

  void _showApplyDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String reason = '';
    String phone = '';
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
                      const Text('Cihaz Başvurusu Yap', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(device['name'], style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Telefon Numaranız',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                        onSaved: (v) => phone = v ?? '',
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Neden bu cihaza ihtiyacınız var?',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                        validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                        onSaved: (v) => reason = v ?? '',
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
                                    final user = Supabase.instance.client.auth.currentUser;
                                    if (user == null) return;

                                    await Supabase.instance.client.from('device_applications').insert({
                                      'user_id': user.id,
                                      'device_id': device['id'],
                                      'reason': reason,
                                      'contact_phone': phone,
                                      'status': 'pending',
                                    });

                                    // Bildirim gönder
                                    await Supabase.instance.client.from('notifications').insert({
                                      'user_id': device['publisher_id'],
                                      'title': 'Yeni Cihaz Başvurusu',
                                      'content': '"${device['name']}" cihazı için yeni bir başvuru aldınız.',
                                    });

                                    if (context.mounted) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Başvurunuz iletildi!'), backgroundColor: Colors.green));
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
                                    }
                                  } finally {
                                    if (context.mounted) setModalState(() => isSubmitting = false);
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.orange),
                        child: isSubmitting 
                            ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: Colors.white), SizedBox(width: 12), Text('Gönderiliyor...')]) 
                            : const Text('BAŞVURUYU TAMAMLA'),
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
    String dateStr = 'Tarih Belirsiz';
    if (device['created_at'] != null) {
      try {
        dateStr = DateFormat('dd.MM.yyyy').format(DateTime.parse(device['created_at'].toString()).toLocal());
      } catch (_) {}
    }
    
    final profile = device['profiles'];
    final publisherName = (profile is Map && profile['full_name'] != null) 
        ? profile['full_name'].toString() 
        : 'İsimsiz Kurum';
        
    final deviceName = device['name']?.toString() ?? 'İsimsiz Cihaz';
    final deviceDesc = device['description']?.toString() ?? 'Açıklama bulunmuyor.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cihaz Detayı'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.devices_other, size: 80, color: Colors.orange.shade600),
              ),
            ),
            const SizedBox(height: 32),
            
            Text(
              deviceName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Icon(Icons.business, color: Colors.orange.shade800),
                const SizedBox(width: 8),
                Text(
                  publisherName,
                  style: TextStyle(fontSize: 18, color: Colors.orange.shade800, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text('İlan Tarihi: $dateStr', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
            
            const Divider(height: 48, thickness: 1),
            
            const Text(
              'Cihaz Detayları ve Özellikleri',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              deviceDesc,
              style: const TextStyle(fontSize: 16, height: 1.6),
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => _showApplyDialog(context),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: const Text('BU CİHAZA BAŞVUR'),
        ),
      ),
    );
  }
}
