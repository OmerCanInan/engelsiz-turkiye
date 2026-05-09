import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'issue_detail_page.dart';

class IssueSharingPage extends StatefulWidget {
  const IssueSharingPage({super.key});

  @override
  State<IssueSharingPage> createState() => _IssueSharingPageState();
}

class _IssueSharingPageState extends State<IssueSharingPage> {
  final _supabase = Supabase.instance.client;
  Future<List<dynamic>>? _issuesFuture;

  @override
  void initState() {
    super.initState();
    _loadIssues();
  }

  void _loadIssues() {
    setState(() {
      _issuesFuture = _supabase
          .from('issues')
          .select('*, profiles(full_name)')
          .order('created_at', ascending: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sorun Paylaşım Sistemi'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadIssues();
          await _issuesFuture;
        },
        child: FutureBuilder<List<dynamic>>(
          future: _issuesFuture,
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
                      Text('Sorunlar yüklenemedi:\n${snapshot.error}', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            }

            final issues = snapshot.data ?? [];
            if (issues.isEmpty) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  alignment: Alignment.center,
                  child: const Text('Henüz hiçbir sorun paylaşılmamış.\nİlk paylaşan siz olun!', textAlign: TextAlign.center),
                ),
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: issues.length,
              itemBuilder: (context, index) {
                final issue = issues[index];
                final authorName = issue['profiles']?['full_name'] ?? 'İsimsiz Kullanıcı';
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => IssueDetailPage(issue: issue)),
                      ).then((_) => _loadIssues());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: const Icon(Icons.person, color: Colors.green),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            issue['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            issue['content'],
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Icon(Icons.comment, size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              const Text('Yorum Yap', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateIssueSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Sorun Paylaş'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showCreateIssueSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String content = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
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
                const Text('Yeni Sorun Paylaş', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Konu Başlığı', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Başlık zorunludur' : null,
                  onSaved: (v) => title = v ?? '',
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Detaylı Açıklama', border: OutlineInputBorder()),
                  maxLines: 5,
                  validator: (v) => v!.isEmpty ? 'Açıklama zorunludur' : null,
                  onSaved: (v) => content = v ?? '',
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();
                      Navigator.pop(ctx);
                      await _createIssue(title, content);
                    }
                  },
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.green),
                  child: const Text('PAYLAŞ'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _createIssue(String title, String content) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('issues').insert({
        'user_id': user.id,
        'title': title,
        'content': content,
      });
      _loadIssues();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sorununuz paylaşıldı.'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
