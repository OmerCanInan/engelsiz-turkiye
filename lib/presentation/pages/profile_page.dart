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

  Future<Map<String, dynamic>>? _profileFuture;
  Future<List<dynamic>>? _companyJobsFuture;
  Future<List<dynamic>>? _userApplicationsFuture;
  Future<List<dynamic>>? _myDevicesFuture;
  Future<List<dynamic>>? _myDeviceApplicationsFuture;

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
    
    _loadMyDevices();
    _loadMyDeviceApplications();

    return data;
  }

  void _loadCompanyJobs() {
    if (_userId == null) return;
    setState(() {
      _companyJobsFuture = _supabase
          .from('jobs')
          .select()
          .eq('company_id', _userId!)
          .order('created_at', ascending: false);
    });
  }

  void _loadUserApplications() {
    if (_userId == null) return;
    setState(() {
      _userApplicationsFuture = _supabase
          .from('job_applications')
          .select('*, jobs(title, company_name)')
          .eq('user_id', _userId!)
          .order('created_at', ascending: false);
    });
  }

  void _loadMyDevices() {
    if (_userId == null) return;
    setState(() {
      _myDevicesFuture = _supabase
          .from('support_devices')
          .select()
          .eq('publisher_id', _userId!)
          .order('created_at', ascending: false);
    });
  }

  void _loadMyDeviceApplications() {
    if (_userId == null) return;
    setState(() {
      _myDeviceApplicationsFuture = _supabase
          .from('device_applications')
          .select('*, support_devices(name)')
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
                  _buildFolderTile('Yayınladığım İlanlar', Icons.work, _buildCompanyJobsList(), Colors.blue),
                  const SizedBox(height: 16),
                  _buildFolderTile('Yayınladığım Cihazlar', Icons.devices_other, _buildMyDevicesList(), Colors.orange),
                ] else ...[
                  _buildFolderTile('İş Başvurularım', Icons.check_circle_outline, _buildUserApplicationsList(), Colors.green),
                  const SizedBox(height: 16),
                  _buildFolderTile('Cihaz Başvurularım', Icons.assignment, _buildMyDeviceApplicationsList(), Colors.purple),
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

  Widget _buildFolderTile(String title, IconData icon, Widget childList, Color color) {
    final bool isTalkBack = MediaQuery.accessibleNavigationOf(context);

    if (isTalkBack) {
      return Card(
        color: Colors.blue.shade900,
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 40, color: Colors.white),
                  const SizedBox(width: 16),
                  Expanded(child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
                ],
              ),
              const SizedBox(height: 24),
              childList,
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          childrenPadding: const EdgeInsets.all(16),
          children: [childList],
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

  Widget _buildMyDevicesList() {
    if (_myDevicesFuture == null) return const Center(child: CircularProgressIndicator());
    return FutureBuilder<List<dynamic>>(
      future: _myDevicesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text('Yayınladığınız cihaz bulunmuyor.');
        return Column(
          children: snapshot.data!.map((device) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(Icons.devices_other, color: Colors.orange),
              title: Text(device['name']),
              onTap: () => _showDeviceApplicantsSheet(context, device),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteDevice(context, device['id']),
              ),
            ),
          )).toList(),
        );
      },
    );
  }

  Widget _buildMyDeviceApplicationsList() {
    if (_myDeviceApplicationsFuture == null) return const Center(child: CircularProgressIndicator());
    return FutureBuilder<List<dynamic>>(
      future: _myDeviceApplicationsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const Text('Cihaz başvurunuz bulunmuyor.');
        return Column(
          children: snapshot.data!.map((app) {
            final device = app['support_devices'];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.handyman, color: Colors.blue),
                title: Text(device?['name'] ?? 'Cihaz silinmiş'),
                subtitle: Text('Durum: ${app['status']}'),
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
                                IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => _updateStatus(app['id'], 'accepted', app['user_id'], job['title'])),
                                IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => _updateStatus(app['id'], 'rejected', app['user_id'], job['title'])),
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
              _detailRow('Telefon:', app['contact_phone']),
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

  void _showDeviceApplicantsSheet(BuildContext context, Map<String, dynamic> device) {
    final applicantsFuture = _supabase
        .from('device_applications')
        .select('*, profiles(full_name)')
        .eq('device_id', device['id']);

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
              Text(device['name'], style: const TextStyle(fontSize: 18, color: Colors.grey)),
              const Text('Cihaz Başvuruları', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: applicantsFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (snap.hasError) return Center(child: Text('HATA:\n${snap.error}', style: const TextStyle(color: Colors.red)));
                    if (!snap.hasData || snap.data!.isEmpty) return const Center(child: Text('Henüz başvuru yok.'));
                    
                    return ListView.builder(
                      controller: controller,
                      itemCount: snap.data!.length,
                      itemBuilder: (_, i) {
                        final app = snap.data![i];
                        final name = app['profiles']?['full_name'] ?? 'Bilinmiyor';
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person, color: Colors.orange)),
                            title: Text(name),
                            subtitle: Text('Durum: ${app['status']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility, color: Colors.blue),
                                  tooltip: 'İncele',
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (ctx2) => AlertDialog(
                                        title: Text('$name - Cihaz Başvurusu'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _detailRow('Telefon:', app['contact_phone']),
                                            const Divider(),
                                            const Text('İhtiyaç Sebebi:', style: TextStyle(fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            Text(app['reason'] ?? 'Belirtilmemiş'),
                                          ],
                                        ),
                                        actions: [TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('KAPAT'))],
                                      ),
                                    );
                                  },
                                ),
                                IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => _updateDeviceStatus(app['id'], 'accepted', app['user_id'], device['name'])),
                                IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => _updateDeviceStatus(app['id'], 'rejected', app['user_id'], device['name'])),
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

  Future<void> _updateStatus(dynamic appId, String status, dynamic applicantUserId, String jobTitle) async {
    try {
      await _supabase.from('job_applications').update({'status': status}).eq('id', appId);
      
      // Bildirim Gönderimi
      String durumMesaji = status == 'accepted' ? 'kabul edildi' : 'reddedildi';
      await _supabase.from('notifications').insert({
        'user_id': applicantUserId,
        'title': 'Başvuru Sonucu',
        'content': '"$jobTitle" başlıklı ilan için yaptığınız başvuru $durumMesaji.',
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Durum güncellendi ve kullanıcıya bildirim gönderildi.')));
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

  Future<void> _updateDeviceStatus(dynamic appId, String status, dynamic applicantUserId, String deviceName) async {
    try {
      await _supabase.from('device_applications').update({'status': status}).eq('id', appId);
      
      String durumMesaji = status == 'accepted' ? 'onaylandı' : 'reddedildi';
      await _supabase.from('notifications').insert({
        'user_id': applicantUserId,
        'title': 'Cihaz Başvuru Sonucu',
        'content': '"$deviceName" cihazı için yaptığınız başvuru $durumMesaji.',
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Durum güncellendi ve bildirim gönderildi.')));
        _fetchProfile();
      }
    } catch (e) {
      debugPrint('Hata: $e');
    }
  }

  Future<void> _deleteDevice(BuildContext context, dynamic deviceId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cihaz İlanını Sil'),
        content: const Text('Silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hayır')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Evet', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await _supabase.from('support_devices').delete().eq('id', deviceId).select();
        
        if (response.isEmpty) {
           if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silinemedi: İlan size ait değil veya RLS/Veritabanı ilişkisi hatası (ON DELETE CASCADE eksik olabilir).'), backgroundColor: Colors.red));
           return;
        }
        
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cihaz başarıyla silindi.'), backgroundColor: Colors.green));
        _loadMyDevices();
        _fetchProfile(); // Genel verileri de yenile
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      }
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
