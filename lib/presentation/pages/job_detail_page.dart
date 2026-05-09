import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/job_model.dart';
import 'package:intl/intl.dart';

class JobDetailPage extends StatelessWidget {
  final Job job;

  const JobDetailPage({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    // Tarih formatlaması
    final dateStr = DateFormat('dd.MM.yyyy').format(job.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İlan Detayı'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst Kısım: Başlık ve Şirket
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.business_center, size: 60, color: Colors.blue.shade700),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              job.title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              job.companyName,
              style: TextStyle(fontSize: 18, color: Colors.blue.shade800, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            
            // Konum, Maaş, Tarih
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
                Text(job.location, style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(job.salaryRange, style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
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
            
            // İş Tanımı
            const Text(
              'İş Tanımı',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              job.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            
            const Divider(height: 48, thickness: 1),
            
            // Gereksinimler
            if (job.requirements.isNotEmpty) ...[
              const Text(
                'Aranan Nitelikler',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...job.requirements.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                    Expanded(child: Text(req, style: const TextStyle(fontSize: 16, height: 1.4))),
                  ],
                ),
              )).toList(),
              const Divider(height: 48, thickness: 1),
            ],

            // Erişilebilirlik
            if (job.friendlyFeatures.isNotEmpty) ...[
              const Text(
                'Erişilebilirlik İmkanları',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: job.friendlyFeatures.map((feat) {
                  return Chip(
                    label: Text(feat),
                    backgroundColor: Colors.green.shade50,
                    side: BorderSide(color: Colors.green.shade200),
                    avatar: const Icon(Icons.accessible_forward, color: Colors.green),
                  );
                }).toList(),
              ),
              const SizedBox(height: 48),
            ],
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
          onPressed: () => _showApplicationForm(context),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: const Text('HEMEN BAŞVUR'),
        ),
      ),
    );
  }

  void _showApplicationForm(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String age = '';
    String expectedSalary = '';
    String experiences = '';
    String coverLetter = '';
    String contactEmail = '';
    String contactPhone = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
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
                  const Text('Başvuru Formu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Yaşınız', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onSaved: (v) => age = v ?? '',
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'İletişim E-posta Adresi', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                    onSaved: (v) => contactEmail = v ?? '',
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Telefon Numaranız', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                    onSaved: (v) => contactPhone = v ?? '',
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Maaş Beklentiniz (Aylık)', border: OutlineInputBorder()),
                    onSaved: (v) => expectedSalary = v ?? '',
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Deneyimleriniz', border: OutlineInputBorder()),
                    maxLines: 2,
                    onSaved: (v) => experiences = v ?? '',
                  ),
                  const SizedBox(height: 12),
                  
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Kendinizden Bahsedin (Ön Yazı)', border: OutlineInputBorder()),
                    maxLines: 3,
                    onSaved: (v) => coverLetter = v ?? '',
                  ),
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        Navigator.pop(ctx);
                        await _submitApplication(context, age, contactEmail, contactPhone, expectedSalary, experiences, coverLetter);
                      }
                    },
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text('BAŞVURUYU TAMAMLA'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitApplication(BuildContext context, String age, String email, String phone, String salary, String exp, String cover) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('job_applications').insert({
        'user_id': user.id,
        'job_id': job.id,
        'age': age,
        'contact_email': email,
        'contact_phone': phone,
        'expected_salary': salary,
        'experiences': exp,
        'cover_letter': cover,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Başvurunuz başarıyla iletildi!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Başvuru hatası: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
