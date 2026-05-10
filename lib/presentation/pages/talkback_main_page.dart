import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'employment_page.dart';
import 'education_page.dart';
import 'sos_system_page.dart';
import 'rights_guide_page.dart';
import 'profile_page.dart';
import 'inbox_page.dart';

class TalkbackMainPage extends StatelessWidget {
  const TalkbackMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Görme engelliler için optimize edilmiş devasa butonlar ve lineer akış
    return Scaffold(
      appBar: AppBar(
        title: Semantics(
          header: true,
          child: const Text('Erişilebilir Türkiye - Ana Menü'),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black, // Yüksek kontrast için siyah arka plan
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTalkbackButton(
            context,
            title: 'Acil Durum Sinyali Gönder',
            hint: 'Yakındaki gönüllülere SOS acil durum sinyali göndermek için çift dokunun.',
            color: Colors.red.shade900,
            icon: Icons.warning,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SosActivePage())),
          ),
          _buildTalkbackButton(
            context,
            title: 'İş İlanları',
            hint: 'Açık iş ilanlarını ve istihdam fırsatlarını görüntülemek için çift dokunun.',
            color: Colors.blue.shade900,
            icon: Icons.work,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EmploymentPage())),
          ),
          _buildTalkbackButton(
            context,
            title: 'Eğitimler',
            hint: 'Sertifikalı eğitim programlarına katılmak için çift dokunun.',
            color: Colors.green.shade900,
            icon: Icons.school,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EducationPage())),
          ),
          _buildTalkbackButton(
            context,
            title: 'Yasal Haklar',
            hint: 'Engelli hakları rehberini dinlemek için çift dokunun.',
            color: Colors.purple.shade900,
            icon: Icons.gavel,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RightsGuidePage())),
          ),
          _buildTalkbackButton(
            context,
            title: 'Bildirimler',
            hint: 'Gelen bildirimlerinizi, mesajları ve başvuru sonuçlarını dinlemek için çift dokunun.',
            color: Colors.teal.shade900,
            icon: Icons.notifications,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InboxPage())),
          ),
          _buildTalkbackButton(
            context,
            title: 'Profil ve Çıkış',
            hint: 'Profil ayarlarınızı yönetmek veya çıkış yapmak için çift dokunun.',
            color: Colors.orange.shade900,
            icon: Icons.person,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage())),
          ),
        ],
      ),
    );
  }

  Widget _buildTalkbackButton(BuildContext context, {required String title, required String hint, required Color color, required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Semantics(
        button: true,
        label: title,
        hint: hint,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 120, // Çok geniş dokunma alanı
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 2), // Yüksek kontrastlı kenarlık
            ),
            child: Row(
              children: [
                const SizedBox(width: 24),
                Icon(icon, size: 64, color: Colors.white),
                const SizedBox(width: 24),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
