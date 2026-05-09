import 'package:flutter/material.dart';

class RightsGuidePage extends StatelessWidget {
  const RightsGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> rightsList = [
      {
        'title': 'Erken Emeklilik Hakkı',
        'icon': Icons.access_time_filled,
        'color': Colors.blue,
        'desc': 'Çalışma gücünde en az %40 kayıp olan engelli bireyler, yaş şartı aranmaksızın erken emeklilik hakkına sahiptir. Gerekli prim gün sayısı engellilik oranına göre değişiklik gösterir.'
      },
      {
        'title': 'Vergi İndirimleri ve Muafiyetler',
        'icon': Icons.request_quote,
        'color': Colors.orange,
        'desc': 'Engelli bireyler; gelir vergisi indirimi, MTV (Motorlu Taşıtlar Vergisi) muafiyeti, ÖTV (Özel Tüketim Vergisi) indirimli araç alımı ve emlak vergisi muafiyeti gibi haklara sahiptir.'
      },
      {
        'title': 'Ücretsiz Ulaşım Hakkı',
        'icon': Icons.directions_bus,
        'color': Colors.green,
        'desc': 'Engelli kimlik kartı sahipleri; belediye otobüsleri, metro, tramvay ve devlet demiryollarından ücretsiz veya indirimli olarak yararlanabilirler. Ayrıca THY iç hat uçuşlarında indirim uygulanır.'
      },
      {
        'title': 'Fatura İndirimleri (Su, Elektrik, İnternet)',
        'icon': Icons.bolt,
        'color': Colors.amber,
        'desc': 'Engelli bireyler; su faturalarında belediyelere göre değişen oranlarda indirim, elektrik tüketim desteği ve telekomünikasyon şirketlerinin sunduğu özel engelli internet/telefon tarifelerinden yararlanabilir.'
      },
      {
        'title': 'EKPSS (Engelli Kamu Personeli Seçme Sınavı)',
        'icon': Icons.account_balance,
        'color': Colors.purple,
        'desc': "Kamuda memur olmak isteyen engelli bireyler için özel olarak düzenlenen EKPSS'ye girme ve kura ile devlet kadrolarına atanma hakkı mevcuttur."
      },
      {
        'title': 'Evde Bakım Maaşı ve Engelli Aylığı',
        'icon': Icons.volunteer_activism,
        'color': Colors.red,
        'desc': 'Ağır engelli raporu olan ve bakıma muhtaç bireylerin yakınlarına evde bakım maaşı; maddi durumu yetersiz olan engelli bireylere ise devlet tarafından düzenli engelli aylığı (2022 maaşı) ödenir.'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yasal Haklar Rehberi'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: rightsList.length,
        itemBuilder: (context, index) {
          final right = rightsList[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: right['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(right['icon'], color: right['color']),
                ),
                title: Text(
                  right['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(
                      right['desc'],
                      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
