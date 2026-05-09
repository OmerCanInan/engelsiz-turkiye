import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _supabase = Supabase.instance.client;
  late final String? _userId;

  // Çökme hatasını önlemek için nullable Future'lar
  Future<Map<String, dynamic>>? _profileFuture;
  Future<List<dynamic>>? _companyJobsFuture;
  Future<List<dynamic>>? _userApplicationsFuture;

  @override
  void initState() {
    super.initState();
    _userId = _supabase.auth.currentUser?.id;
    if (_userId != null) {
      _profileFuture = _fetchProfile();
    }
  }

  Future<Map<String, dynamic>> _fetchProfile() async {
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', _userId!)
        .single();

    // Rolü öğrendikten sonra ilgili listeyi başlat
    if (data['role'] == 'company') {
      _loadCompanyJobs();
    } else {
      _loadUserApplications();
    }

    return data;
  }

  void _loadCompanyJobs() {
    setState(() {
      _companyJobsFuture = _supabase
          .from('jobs')
          .select()
          .eq('company_id', _userId!)
          .order('created_at', ascending: false);
    });
  }

  void _loadUserApplications() {
    setState(() {
      _userApplicationsFuture = _supabase
          .from('job_applications')
          .select('*, jobs(title, company_name)')
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(body: Center(child: Text('Giriş yapılmadı.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          
          final profile = snapshot.data!;
          final isCompany = profile['role'] == 'company';
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileCard(profile, isCompany),
                const SizedBox(height: 24),
                
                if (isCompany) ...[
                  const Text('Yayınladığım İlanlar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildCompanyJobsList(),
                ] else ...[
                  const Text('Başvurularım', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildUserApplicationsList(),
                ],
                
                const SizedBox(height: 48),
                _buildLogoutButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(Map<String, dynamic> profile, bool isCompany) {
    return Card(
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
            Text(_supabase.auth.currentUser?.email ?? '', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Chip(
              label: Text(isCompany ? 'Şirket (İşveren)' : 'Kullanıcı', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              backgroundColor: isCompany ? Colors.orange : Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyJobsList() {
    if (_companyJobsFuture == null) return const Center(child: CircularProgressIndicator());
    return FutureBuilder<List<dynamic>>(
      future: _companyJobsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text('Henüz ilanınız yok.');
        return Column(
          children: snapshot.data!.map((job) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.work, color: Colors.blue),
              title: Text(job['title']),
              subtitle: Text(job['location']),
              onTap: () => _showApplicantsSheet(context, job),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteJob(context, job['id']),
              ),
            ),
          )).toList(),
        );
      },
    );
  }

  Widget _buildUserApplicationsList() {
    if (_userApplicationsFuture == null) return const Center(child: CircularProgressIndicator());
    return FutureBuilder<List<dynamic>>(
      future: _userApplicationsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text('Henüz başvuru yok.');
        return Column(
          children: snapshot.data!.map((app) {
            final job = app['jobs'];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(job['title'] ?? 'İlan silinmiş'),
                subtitle: Text('${job['company_name']} - Durum: ${app['status']}'),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showApplicantsSheet(BuildContext context, Map<String, dynamic> job) {
    final applicantsFuture = _supabase
        .from('job_applications')
        .select('*, profiles(full_name)')
        .eq('job_id', job['id']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(job['title'], style: const TextStyle(fontSize: 18, color: Colors.grey)),
              const Text('Gelen Başvurular', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: applicantsFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    
                    if (snap.hasError) {
                      return Center(
                        child: Text(
                          'HATA OLUŞTU:\n${snap.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    if (!snap.hasData || snap.data!.isEmpty) return const Center(child: Text('Başvuru yok.'));
                    
                    return ListView.builder(
                      controller: controller,
                      itemCount: snap.data!.length,
                      itemBuilder: (_, i) {
                        final app = snap.data![i];
                        final name = app['profiles']?['full_name'] ?? 'Bilinmiyor';
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(name),
                            subtitle: Text('Durum: ${app['status']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility, color: Colors.blue),
                                  tooltip: 'İncele',
                                  onPressed: () => _showApplicantDetails(context, name, app),
                                ),
                                IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => _updateStatus(app['id'], 'accepted')),
                                IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => _updateStatus(app['id'], 'rejected')),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showApplicantDetails(BuildContext context, String name, Map<String, dynamic> app) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$name - Başvuru Detayı'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Yaş:', app['age']),
              _detailRow('E-posta:', app['contact_email']),
              _detailRow('Beklenen Maaş:', app['expected_salary']),
              const Divider(),
              const Text('Deneyimler:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(app['experiences'] ?? 'Belirtilmemiş'),
              const Divider(),
              const Text('Ön Yazı:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(app['cover_letter'] ?? 'Belirtilmemiş'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('KAPAT')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(child: Text(value?.toString() ?? 'Belirtilmemiş')),
        ],
      ),
    );
  }

  Future<void> _updateStatus(dynamic appId, String status) async {
    try {
      await _supabase.from('job_applications').update({'status': status}).eq('id', appId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Durum güncellendi.')));
        _fetchProfile(); // Veriyi yenile
      }
    } catch (e) {
      debugPrint('Hata: $e');
    }
  }

  Future<void> _deleteJob(BuildContext context, dynamic jobId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('İlanı Sil'),
        content: const Text('Silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hayır')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Evet', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _supabase.from('jobs').delete().eq('id', jobId);
      _loadCompanyJobs();
    }
  }

  Widget _buildLogoutButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.logout),
      label: const Text('ÇIKIŞ YAP'),
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red, minimumSize: const Size(double.infinity, 50)),
      onPressed: () async {
        await AuthService().signOut();
        if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }
}
