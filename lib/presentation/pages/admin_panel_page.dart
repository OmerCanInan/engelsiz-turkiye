import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;

  Future<List<dynamic>>? _companiesFuture;
  Future<List<dynamic>>? _educationsFuture;
  Future<List<dynamic>>? _roadReportsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() {
    setState(() {
      _companiesFuture = _supabase.from('profiles').select().eq('role', 'company').eq('approval_status', 'pending');
      _educationsFuture = _supabase.from('education_materials').select().eq('status', 'pending');
      _roadReportsFuture = _supabase.from('road_reports').select().eq('status', 'pending');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Paneli'),
        centerTitle: true,
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Yenile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _supabase.auth.signOut();
            },
            tooltip: 'Çıkış Yap',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.red.shade200,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.business), text: 'Şirket İstekleri'),
            Tab(icon: Icon(Icons.school), text: 'Eğitim İstekleri'),
            Tab(icon: Icon(Icons.report_problem), text: 'Yol Bildirimleri'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCompanyApprovals(),
          _buildEducationApprovals(),
          _buildRoadReports(),
        ],
      ),
    );
  }

  Widget _buildCompanyApprovals() {
    return FutureBuilder<List<dynamic>>(
      future: _companiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('Bekleyen şirket onayı bulunmuyor.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final company = items[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(company['full_name'] ?? 'İsimsiz Şirket', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Açıklama: ${company['company_description'] ?? 'Belirtilmemiş'}', maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green, size: 32),
                      onPressed: () => _updateCompanyStatus(company['id'], 'approved'),
                      tooltip: 'Onayla',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red, size: 32),
                      onPressed: () => _updateCompanyStatus(company['id'], 'rejected'),
                      tooltip: 'Reddet',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEducationApprovals() {
    return FutureBuilder<List<dynamic>>(
      future: _educationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}\nVeritabanında status sütunu olmayabilir.'));
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('Bekleyen eğitim onayı bulunmuyor.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final edu = items[index];
            final dateStr = DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(edu['created_at']).toLocal());
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                title: Text(edu['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('Yayıncı: ${edu['publisher_name']}'),
                    Text('Kategori: ${edu['target_audience']} - ${edu['category']}'),
                    Text('Tarih: $dateStr'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green, size: 32),
                      onPressed: () => _updateEduStatus(edu['id'], 'approved'),
                      tooltip: 'Onayla',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red, size: 32),
                      onPressed: () => _updateEduStatus(edu['id'], 'rejected'),
                      tooltip: 'Reddet',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateCompanyStatus(dynamic id, String status) async {
    try {
      final response = await _supabase.from('profiles').update({'approval_status': status}).eq('id', id).select();
      if (response.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hata: Supabase yetkilendirme (RLS) kısıtlaması nedeniyle güncellenemedi.')));
        return;
      }
      _loadData();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Şirket durumu: $status')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }

  Future<void> _updateEduStatus(dynamic id, String status) async {
    try {
      final response = await _supabase.from('education_materials').update({'status': status}).eq('id', id).select();
      if (response.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hata: Supabase yetkilendirme (RLS) kısıtlaması nedeniyle güncellenemedi.')));
        return;
      }
      _loadData();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Eğitim durumu: $status')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }
  Widget _buildRoadReports() {
    return FutureBuilder<List<dynamic>>(
      future: _roadReportsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}\nVeritabanında road_reports tablosu bulunmayabilir.'));
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('Bekleyen yol hata bildirimi bulunmuyor.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final report = items[index];
            final dateStr = report['created_at'] != null 
              ? DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(report['created_at']).toLocal())
              : 'Tarih Yok';
            
            final lat = report['latitude'];
            final lng = report['longitude'];

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange, size: 40),
                title: Text('Hata Bildirimi ($dateStr)', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Detay: ${report['description']}'),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harita açılamadı.')));
                        }
                      },
                      child: Text(
                        'Konumu Haritada Gör ($lat, $lng)',
                        style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _updateRoadReportStatus(dynamic id, String status) async {
    try {
      final response = await _supabase.from('road_reports').update({'status': status}).eq('id', id).select();
      if (response.isEmpty) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hata: RLS kısıtlaması nedeniyle güncellenemedi.')));
        return;
      }
      _loadData();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bildirim durumu: $status')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
    }
  }
}
