import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'video_player_page.dart';

class EducationCategoryPage extends StatefulWidget {
  final String categoryName;
  final String targetAudience;

  const EducationCategoryPage({
    super.key,
    required this.categoryName,
    required this.targetAudience,
  });

  @override
  State<EducationCategoryPage> createState() => _EducationCategoryPageState();
}

class _EducationCategoryPageState extends State<EducationCategoryPage> {
  final _supabase = Supabase.instance.client;
  Future<List<dynamic>>? _educationsFuture;

  @override
  void initState() {
    super.initState();
    _loadEducations();
  }

  void _loadEducations() {
    setState(() {
      _educationsFuture = _supabase
          .from('education_materials')
          .select()
          .eq('category', widget.categoryName)
          .eq('target_audience', widget.targetAudience)
          .order('created_at', ascending: false);
    });
  }

  void _showAddEducationSheet() {
    final formKey = GlobalKey<FormState>();
    String titleDesc = '';
    String publisherName = '';
    File? selectedFile;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickFile() async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['mp4', 'mp3', 'avi', 'mov', 'mkv'],
              );

              if (result != null && result.files.single.path != null) {
                setModalState(() {
                  selectedFile = File(result.files.single.path!);
                });
              }
            }

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
                      const Text('Yeni Eğitim Ekle', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('${widget.targetAudience} - ${widget.categoryName}', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 24),
                      
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Eğitim Açıklaması / Başlığı',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                        onSaved: (v) => titleDesc = v ?? '',
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Yayıncı / Eğitmen İsmi',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Zorunlu alan' : null,
                        onSaved: (v) => publisherName = v ?? '',
                      ),
                      const SizedBox(height: 16),
                      
                      InkWell(
                        onTap: pickFile,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.video_file, color: selectedFile == null ? Colors.grey : Colors.blue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  selectedFile == null 
                                      ? 'Video veya Ses Dosyası Seç (mp4, mp3)' 
                                      : selectedFile!.path.split('\\').last,
                                  style: TextStyle(color: selectedFile == null ? Colors.grey : Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (formKey.currentState!.validate()) {
                                  if (selectedFile == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen bir medya dosyası seçin!'), backgroundColor: Colors.red));
                                    return;
                                  }

                                  formKey.currentState!.save();
                                  setModalState(() => isSubmitting = true);
                                  
                                  try {
                                    final fileExt = selectedFile!.path.split('.').last;
                                    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
                                    
                                    // Dosyayı Supabase'e yükle
                                    await _supabase.storage
                                        .from('education_media')
                                        .upload(fileName, selectedFile!);
                                        
                                    // Public URL al
                                    final publicUrl = _supabase.storage
                                        .from('education_media')
                                        .getPublicUrl(fileName);

                                    // Veritabanına yaz
                                    await _supabase.from('education_materials').insert({
                                      'category': widget.categoryName,
                                      'target_audience': widget.targetAudience,
                                      'title': titleDesc,
                                      'publisher_name': publisherName,
                                      'media_url': publicUrl,
                                    });

                                    if (mounted) {
                                      Navigator.pop(ctx);
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eğitim başarıyla yüklendi!'), backgroundColor: Colors.green));
                                      _loadEducations();
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
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                        child: isSubmitting 
                            ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: Colors.white), SizedBox(width: 12), Text('Yükleniyor...')]) 
                            : const Text('EĞİTİMİ KAYDET'),
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
        title: Text(widget.categoryName),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _educationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata oluştu:\n${snapshot.error}', textAlign: TextAlign.center));
          }

          final educations = snapshot.data ?? [];
          if (educations.isEmpty) {
            return const Center(
              child: Text(
                'Bu kategoride henüz eğitim yok.\nSağ alt köşeden yeni bir eğitim ekleyebilirsiniz.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: educations.length,
            itemBuilder: (context, index) {
              final item = educations[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.blue, size: 32),
                  ),
                  title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Yayıncı: ${item['publisher_name']}', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPlayerPage(
                          videoUrl: item['media_url'],
                          title: item['title'],
                        ),
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
        onPressed: _showAddEducationSheet,
        icon: const Icon(Icons.add),
        label: const Text('Eğitim Ekle'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
