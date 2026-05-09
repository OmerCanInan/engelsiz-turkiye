import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'education_category_page.dart';
import 'inbox_page.dart';

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> gormeEngellilerKategorileri = [
    'Şirketlerin Yayınladığı Eğitimler',
    'Genel Eğitimler',
  ];

  final List<String> gormeEngelliOlmayanlarKategorileri = [
    'İşaret Dili Eğitimi',
    'Şirketler İçin Eğitimler',
    'Genel Eğitimler',
    'Öğrenme Engeli Olanlara Özel Eğitimler',
    'Duyma Engeli Olanlar İçin Özel Eğitimler',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: const Text('Eğitimler'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const InboxPage()));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.blue.shade700,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue.shade700,
          tabs: const [
            Tab(text: 'Görme Engelliler İçin'),
            Tab(text: 'Görme Engelli Olmayanlar İçin'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Tab: Görme Engelliler
          _buildCategoryList(gormeEngellilerKategorileri, 'Görme Engelliler'),
          
          // 2. Tab: Görme Engelli Olmayanlar
          _buildCategoryList(gormeEngelliOlmayanlarKategorileri, 'Diğer Bireyler'),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<String> categories, String targetAudience) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.folder, color: Colors.white),
            ),
            title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              // Alt klasöre git (ilgili eğitim listesini görecek)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EducationCategoryPage(
                    categoryName: category,
                    targetAudience: targetAudience,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
