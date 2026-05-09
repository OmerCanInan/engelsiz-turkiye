import 'package:flutter/material.dart';
import '../../data/models/job_model.dart';
import '../../data/repositories/job_repository.dart';

class EmploymentPage extends StatefulWidget {
  const EmploymentPage({super.key});

  @override
  State<EmploymentPage> createState() => _EmploymentPageState();
}

class _EmploymentPageState extends State<EmploymentPage> {
  final _repository = JobRepository();
  late Future<List<Job>> _jobsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _jobsFuture = _repository.getJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _jobsFuture = _repository.searchJobs(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Erişilebilir İstihdam'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'İş veya şirket ara...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                fillColor: Colors.grey[200],
              ),
              onChanged: (v) {
                setState(() {
                  _jobsFuture = _repository.searchJobs(v);
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Job>>(
        future: _jobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    const Text('PostgreSQL Veritabanı Hatası', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() { _jobsFuture = _repository.getJobs(); }),
                      child: const Text('TEKRAR DENE'),
                    ),
                  ],
                ),
              ),
            );
          }
          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) {
            return const Center(child: Text('Henüz iş ilanı bulunmuyor.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.business, color: Colors.blue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                Text(job.companyName, style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: job.friendlyFeatures.map((feat) {
                          return Chip(
                            label: Text(feat, style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.green[50],
                            side: BorderSide.none,
                            avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(job.location, style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text(job.salaryRange, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          // Detay sayfasına git
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                        ),
                        child: const Text('İLAN DETAYI'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (context) => _CreateJobSheet(onSaved: () {
              setState(() {
                _jobsFuture = _repository.getJobs();
              });
            }),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni İlan Aç'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _CreateJobSheet extends StatefulWidget {
  final VoidCallback onSaved;
  const _CreateJobSheet({required this.onSaved});

  @override
  State<_CreateJobSheet> createState() => _CreateJobSheetState();
}

class _CreateJobSheetState extends State<_CreateJobSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _featuresController = TextEditingController();
  final _requirementsController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _salaryController.dispose();
    _featuresController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      // Virgülle ayrılmış metni listeye çeviriyoruz
      final featuresList = _featuresController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
          
      final reqList = _requirementsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      await JobRepository().createJob(
        title: _titleController.text,
        companyName: _companyController.text,
        description: _descController.text,
        location: _locationController.text,
        salaryRange: _salaryController.text,
        friendlyFeatures: featuresList,
        requirements: reqList,
      );
      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('İlan başarıyla yayınlandı!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Yeni İş İlanı Oluştur', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'İlan Başlığı (Örn: Yazılım Uzmanı)', prefixIcon: Icon(Icons.work)),
                validator: (v) => v!.isEmpty ? 'Başlık zorunlu' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Şirket Adı', prefixIcon: Icon(Icons.business)),
                validator: (v) => v!.isEmpty ? 'Şirket adı zorunlu' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Çalışma Yeri (Örn: İstanbul - Uzaktan)', prefixIcon: Icon(Icons.location_on)),
                validator: (v) => v!.isEmpty ? 'Konum zorunlu' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(labelText: 'Maaş Aralığı (Örn: 20.000₺ - 30.000₺)', prefixIcon: Icon(Icons.attach_money)),
                validator: (v) => v!.isEmpty ? 'Maaş aralığı zorunlu' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _featuresController,
                decoration: const InputDecoration(labelText: 'Erişilebilirlik İmkanları (Virgülle ayırın)', hintText: 'Örn: Rampa, Esnek Saatler', prefixIcon: Icon(Icons.accessible)),
                validator: (v) => v!.isEmpty ? 'En az 1 imkan ekleyin' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _requirementsController,
                decoration: const InputDecoration(labelText: 'İş Gereksinimleri (Virgülle ayırın)', hintText: 'Örn: Lise Mezunu, B Sınıfı Ehliyet', prefixIcon: Icon(Icons.checklist)),
                validator: (v) => v!.isEmpty ? 'En az 1 gereksinim ekleyin' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'İş Tanımı ve Detaylar', prefixIcon: Icon(Icons.description)),
                validator: (v) => v!.isEmpty ? 'Açıklama zorunlu' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('İLANI YAYINLA'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
