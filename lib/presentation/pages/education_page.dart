import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'education_category_page.dart';
import 'inbox_page.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isTalkBack = MediaQuery.accessibleNavigationOf(context);

    if (isTalkBack) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Eğitim Akademisi', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            Semantics(
              header: true,
              child: const Text(
                'Görme Engelliler İçin Eğitimler',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            _buildCategoryGrid(
              context,
              targetAudience: 'Görme Engelliler',
              categories: [
                {'title': 'Şirketlerin Yayınladığı Eğitimler', 'icon': Icons.business, 'color': Colors.blue.shade900},
                {'title': 'Genel Eğitimler', 'icon': Icons.public, 'color': Colors.blue.shade900},
              ],
            ),
            const SizedBox(height: 32),
            Semantics(
              header: true,
              child: const Text(
                'Diğer Bireyler İçin Eğitimler',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            _buildCategoryGrid(
              context,
              targetAudience: 'Diğer Bireyler',
              categories: [
                {'title': 'İşaret Dili Eğitimi', 'icon': Icons.sign_language, 'color': Colors.blue.shade900},
                {'title': 'Şirketler İçin Eğitimler', 'icon': Icons.business_center, 'color': Colors.blue.shade900},
                {'title': 'Öğrenme Engeli Olanlara Özel', 'icon': Icons.psychology, 'color': Colors.blue.shade900},
                {'title': 'Duyma Engeli Olanlara Özel', 'icon': Icons.hearing_disabled, 'color': Colors.blue.shade900},
                {'title': 'Genel Eğitimler', 'icon': Icons.library_books, 'color': Colors.blue.shade900},
              ],
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Eğitim Akademisi', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.notifications, color: Colors.blue),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const InboxPage()));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.blue),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderBanner(),
            const SizedBox(height: 32),
            _buildSectionHeader('Görme Engelliler İçin', Icons.visibility_off, Colors.indigo),
            const SizedBox(height: 16),
            _buildCategoryGrid(
              context,
              targetAudience: 'Görme Engelliler',
              categories: [
                {'title': 'Şirketlerin Yayınladığı Eğitimler', 'icon': Icons.business, 'color': Colors.indigo},
                {'title': 'Genel Eğitimler', 'icon': Icons.public, 'color': Colors.blue},
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionHeader('Diğer Bireyler İçin', Icons.group, Colors.teal),
            const SizedBox(height: 16),
            _buildCategoryGrid(
              context,
              targetAudience: 'Diğer Bireyler',
              categories: [
                {'title': 'İşaret Dili Eğitimi', 'icon': Icons.sign_language, 'color': Colors.teal},
                {'title': 'Şirketler İçin Eğitimler', 'icon': Icons.business_center, 'color': Colors.green},
                {'title': 'Öğrenme Engeli Olanlara Özel', 'icon': Icons.psychology, 'color': Colors.orange},
                {'title': 'Duyma Engeli Olanlara Özel', 'icon': Icons.hearing_disabled, 'color': Colors.redAccent},
                {'title': 'Genel Eğitimler', 'icon': Icons.library_books, 'color': Colors.purple},
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Öğrenmenin Sınırı Yok!',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Size özel hazırlanan eğitimlere hemen başlayın.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          SizedBox(width: 16),
          Icon(Icons.school, color: Colors.white, size: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context, {required String targetAudience, required List<Map<String, dynamic>> categories}) {
    final bool isTalkBack = MediaQuery.accessibleNavigationOf(context);

    if (isTalkBack) {
      return Column(
        children: categories.map((category) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Semantics(
              button: true,
              label: '${category['title']} kategorisi. Girmek için çift dokunun.',
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 100),
                  backgroundColor: category['color'],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EducationCategoryPage(categoryName: category['title'], targetAudience: targetAudience)));
                },
                child: Row(
                  children: [
                    Icon(category['icon'], size: 40),
                    const SizedBox(width: 16),
                    Expanded(child: Text(category['title'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        final Color color = category['color'];
        
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EducationCategoryPage(
                  categoryName: category['title'],
                  targetAudience: targetAudience,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
              ],
              border: Border.all(color: color.withOpacity(0.2), width: 1),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(category['icon'], color: color, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  category['title'],
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
