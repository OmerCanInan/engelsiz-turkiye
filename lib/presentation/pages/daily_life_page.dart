import 'package:flutter/material.dart';
import 'profile_page.dart';
import 'rights_guide_page.dart';
import 'issue_sharing_page.dart';
import 'inbox_page.dart';
import 'device_support_page.dart';

class DailyLifePage extends StatelessWidget {
  const DailyLifePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Cihaz Destek Sistemi',
        'icon': Icons.devices_other,
        'color': Colors.blue,
        'desc': 'Erişilebilirlik cihazları hakkında destek ve kılavuzlar.'
      },
      {
        'title': 'Yol Hata Bildirim Sistemi',
        'icon': Icons.report_problem_outlined,
        'color': Colors.orange,
        'desc': 'Bozuk yol, rampa eksikliği veya asansör arızalarını bildirin.'
      },
      {
        'title': 'Hak Rehberi Sistemi',
        'icon': Icons.gavel,
        'color': Colors.purple,
        'desc': 'Yasal haklarınız ve yasal danışmanlık rehberi.'
      },
      {
        'title': 'SOS Gönüllü Sistemi',
        'icon': Icons.sos,
        'color': Colors.red,
        'desc': 'Acil durumlarda yakındaki gönüllülerden yardım isteyin.'
      },
      {
        'title': 'Sorun Paylaşım Sistemi',
        'icon': Icons.forum_outlined,
        'color': Colors.green,
        'desc': 'Karşılaştığınız sorunları toplulukla paylaşın ve tartışın.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Hayat'),
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
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (item['title'] == 'Hak Rehberi Sistemi') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RightsGuidePage()));
                } else if (item['title'] == 'Sorun Paylaşım Sistemi') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const IssueSharingPage()));
                } else if (item['title'] == 'Cihaz Destek Sistemi') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const DeviceSupportPage()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item['title']} yakında eklenecek!')),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'],
                        color: item['color'],
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['desc'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
