import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = Supabase.instance.client.auth.currentUser;
  late Future<Map<String, dynamic>> _profileFuture;
  late Future<List<dynamic>> _companyJobsFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
  }

  Future<Map<String, dynamic>> _fetchProfile() async {
    if (user == null) throw Exception("Kullanıcı bulunamadı");
    
    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user!.id)
        .single();
        
    if (data['role'] == 'company') {
      _companyJobsFuture = Supabase.instance.client
          .from('jobs')
          .select()
          .eq('company_id', user!.id)
          .order('created_at', ascending: false);
    }
    
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Profil yüklenemedi: ${snapshot.error}'));
          }
          
          final profile = snapshot.data!;
          final isCompany = profile['role'] == 'company';
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profil Kartı
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: isCompany ? Colors.orange.shade100 : Colors.blue.shade100,
                          child: Icon(isCompany ? Icons.business : Icons.person, size: 50, color: isCompany ? Colors.orange : Colors.blue),
                        ),
                        const SizedBox(height: 16),
                        Text(profile['full_name'] ?? 'İsimsiz', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(user?.email ?? '', style: const TextStyle(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(isCompany ? 'Şirket (İşveren)' : 'Kullanıcı', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          backgroundColor: isCompany ? Colors.orange : Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Rol Bazlı İçerik
                if (isCompany) ...[
                  const Text('Yayınladığım İlanlar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  FutureBuilder<List<dynamic>>(
                    future: _companyJobsFuture,
                    builder: (context, jobSnap) {
                      if (jobSnap.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
                      if (jobSnap.hasError || jobSnap.data == null || jobSnap.data!.isEmpty) {
                        return const Text('Henüz ilan yayınlamadınız.', style: TextStyle(color: Colors.grey));
                      }
                      
                      return Column(
                        children: jobSnap.data!.map((job) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.work, color: Colors.blue),
                            title: Text(job['title']),
                            subtitle: Text(job['location']),
                            onTap: () {
                              _showApplicantsSheet(context, job);
                            },
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteJob(context, job['id']),
                            ),
                          ),
                        )).toList(),
                      );
                    },
                  ),
                ] else ...[
                  const Text('Başvurularım', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                        child: const Icon(Icons.check_circle, color: Colors.green),
                      ),
                      title: const Text('Yazılım Uzmanı - Tech A.Ş.'),
                      subtitle: const Text('Durum: İnceleniyor'),
                    ),
                  ),
                ],
                
                const SizedBox(height: 48),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('ÇIKIŞ YAP'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () => AuthService().signOut(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Şirketin ilanını silme metodu
  Future<void> _deleteJob(BuildContext context, String jobId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlanı Sil'),
        content: const Text('Bu iş ilanını tamamen silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('İPTAL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('SİL', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client.from('jobs').delete().eq('id', jobId);
        
        // Listeyi anında yenilemek için Future'ı tekrar oluşturuyoruz
        if (mounted) {
          setState(() {
            _companyJobsFuture = Supabase.instance.client
                .from('jobs')
                .select()
                .eq('company_id', user!.id)
                .order('created_at', ascending: false);
          });
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İlan başarıyla silindi.'), backgroundColor: Colors.green));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Silme Hatası: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }

  // Başvuranları gösterme metodu (Hackathon için tasarımsal simülasyon)
  void _showApplicantsSheet(BuildContext context, Map<String, dynamic> job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('${job['title']}', style: const TextStyle(fontSize: 18, color: Colors.grey)),
              const Text('Gelen Başvurular', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // Örnek Başvuran 1
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
                title: const Text('Ahmet Yılmaz', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Ortopedik Engelli - %40\nLise Mezunu • 3 Yıl Tecrübe'),
                isThreeLine: true,
                trailing: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Özgeçmiş indiriliyor...')));
                  },
                  style: ElevatedButton.styleFrom(visualDensity: VisualDensity.compact),
                  child: const Text('CV İncele'),
                ),
              ),
              const Divider(),
              
              // Örnek Başvuran 2
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(backgroundColor: Colors.purple, child: Icon(Icons.person, color: Colors.white)),
                title: const Text('Zeynep Demir', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('İşitme Engelli - %50\nÜniversite Mezunu • 1 Yıl Tecrübe'),
                isThreeLine: true,
                trailing: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Özgeçmiş indiriliyor...')));
                  },
                  style: ElevatedButton.styleFrom(visualDensity: VisualDensity.compact),
                  child: const Text('CV İncele'),
                ),
              ),
              
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('KAPAT'),
              )
            ],
          ),
        );
      }
    );
  }
}
