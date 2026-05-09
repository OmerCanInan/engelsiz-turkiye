import 'package:flutter/material.dart';

class RightsGuidePage extends StatelessWidget {
  const RightsGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> rightsList = [
      {'title': 'ÖTV Muafiyetli Araç Alımı', 'icon': Icons.directions_car, 'color': Colors.blue, 'desc': '%90 ve üzeri engel raporu olan bireyler, 5 yılda bir sıfır kilometre araç alımlarında Özel Tüketim Vergisi\'nden muaf tutulur.'},
      {'title': 'Motorlu Taşıtlar Vergisi (MTV) Muafiyeti', 'icon': Icons.car_rental, 'color': Colors.indigo, 'desc': 'Engelli birey adına kayıtlı olan ve engel durumuna uygun aparatlı (veya %90 raporlu) araçlar için her yıl ödenen MTV\'den muafiyet sağlanır.'},
      {'title': 'Gelir Vergisi İndirimi', 'icon': Icons.request_quote, 'color': Colors.green, 'desc': 'Engelli çalışanlar veya bakmakla yükümlü olduğu engelli yakını bulunanlar, engel derecelerine göre maaşlarının bir kısmını vergiden muaf alarak net ücret artışı sağlar.'},
      {'title': 'Emlak Vergisi Muafiyeti', 'icon': Icons.home, 'color': Colors.brown, 'desc': 'Brüt alanı 200 metrekareyi geçmeyen ve tek konutu olan engelliler, belediyelere başvurarak emlak vergisinden tamamen muaf olur.'},
      {'title': 'Gümrük Vergisi İstisnası', 'icon': Icons.local_shipping, 'color': Colors.teal, 'desc': 'Engellilerin kullanımı için özel olarak imal edilmiş araç, gereç ve özel tertibatlı otomobillerin ithalatında gümrük vergisi ödenmez.'},
      {'title': 'KDV İstisnası', 'icon': Icons.money_off, 'color': Colors.red, 'desc': 'Engellilerin eğitimleri, meslekleri ve günlük yaşamları için özel üretilmiş her türlü araç-gereç (tekerlekli sandalye, konuşan kitap vb.) KDV’den muaftır.'},
      {'title': 'Şehir İçi Ücretsiz Ulaşım', 'icon': Icons.directions_bus, 'color': Colors.orange, 'desc': 'Belediyelere bağlı toplu taşıma araçları (otobüs, metro, vapur, metrobüs) engelli kartı ibrazıyla ücretsiz kullanılır.'},
      {'title': 'Refakatçi Ulaşım Hakkı', 'icon': Icons.accessible_forward, 'color': Colors.deepOrange, 'desc': 'Raporunda "Ağır Engelli" veya "Tam Bağımlı" ibaresi bulunan bireyin yanındaki bir refakatçisi de şehir içi ulaşımdan ücretsiz yararlanır.'},
      {'title': 'TCDD ve Şehirler Arası Tren İndirimi', 'icon': Icons.train, 'color': Colors.grey, 'desc': 'Devlet demiryollarına ait ana hat ve yüksek hızlı trenlerde engelliler ücretsiz, ağır engelli refakatçileri de ücretsiz seyahat eder.'},
      {'title': 'Türk Hava Yolları (THY) İndirimi', 'icon': Icons.flight, 'color': Colors.lightBlue, 'desc': 'İç hatlarda %20, dış hatlarda %25 oranında indirim uygulanır (İndirimli biletler genellikle ofislerden veya sistem tanımlamasıyla alınır).'},
      {'title': 'Şehirler Arası Otobüs İndirimi', 'icon': Icons.directions_transit, 'color': Colors.blueGrey, 'desc': 'Karayolu Taşıma Yönetmeliği uyarınca, otobüs firmaları engelli bireylere bilet fiyatı üzerinden %40 indirim yapmak zorundadır.'},
      {'title': 'Ücretsiz Otopark Hakkı', 'icon': Icons.local_parking, 'color': Colors.amber, 'desc': 'Kamu kurumlarına ait otoparklar, havalimanı otoparkları ve belediyelerin işlettiği (İSPARK vb.) açık otoparklar belirli sürelerle engelli araçlarına ücretsizdir.'},
      {'title': 'Özel Park Yeri Tahsisi', 'icon': Icons.add_road, 'color': Colors.black, 'desc': 'Engelli bireyler, evlerinin veya iş yerlerinin önüne belediyeye başvurarak sadece kendi araçlarının park edebileceği "Engelli Park Yeri" tabelası diktirebilir.'},
      {'title': 'E-KPSS Sınav Hakkı', 'icon': Icons.assignment, 'color': Colors.purple, 'desc': 'Engelli bireylerin kamuda memur olabilmeleri için engel gruplarına (görme, işitme, zihinsel) göre özelleştirilmiş ayrı bir merkezi sınav hakkı bulunur.'},
      {'title': 'Kamuda Kota Uygulaması', 'icon': Icons.account_balance, 'color': Colors.blueAccent, 'desc': 'Kamu kurumları, toplam kadro sayılarının en az %4’ünü engelli personele ayırmak ve bu kadroları boş bırakmamak zorundadır.'},
      {'title': 'Özel Sektörde Kota Uygulaması', 'icon': Icons.business, 'color': Colors.cyan, 'desc': '50 ve üzeri çalışanı olan özel sektör iş yerleri, toplam çalışan sayısının %3’ü oranında engelli personel istihdam etmekle yükümlüdür.'},
      {'title': 'Erken Emeklilik Hakkı', 'icon': Icons.access_time_filled, 'color': Colors.green, 'desc': 'Engelli çalışanlar, yaş şartına bakılmaksızın; engel oranına göre 15 ile 20 yıl arasında değişen sigortalılık süresi ve prim gününü tamamlayarak emekli olabilir.'},
      {'title': 'Gece Mesaisi ve Nöbet Muafiyeti', 'icon': Icons.nights_stay, 'color': Colors.indigo, 'desc': 'Engelli memurlar, kendi istekleri ve onayları dışında gece vardiyasında çalıştırılamaz ve gece nöbetine zorlanamaz.'},
      {'title': 'İdari İzin Hakkı', 'icon': Icons.ac_unit, 'color': Colors.lightBlueAccent, 'desc': 'Olumsuz hava koşulları (kar, buzlanma vb.) nedeniyle valiliklerce tatil edilen günlerde, engelli kamu personeli ayrıca bir talimata gerek kalmadan izinli sayılır.'},
      {'title': 'Bir Defaya Mahsus Tayin Hakkı', 'icon': Icons.transfer_within_a_station, 'color': Colors.deepPurple, 'desc': 'Engelli devlet memurları, kendisi veya bakmakla yükümlü olduğu engelli yakını nedeniyle meslek hayatı boyunca bir kez istediği yere tayin olabilir.'},
      {'title': 'İş Kurma Hibe Desteği', 'icon': Icons.monetization_on, 'color': Colors.teal, 'desc': 'İŞKUR, kendi işini kurmak isteyen engelli girişimcilere belirli bir projeye dayalı olarak yüksek tutarlı hibe destekleri sağlamaktadır.'},
      {'title': 'Özel Eğitim ve Rehabilitasyon Desteği', 'icon': Icons.school, 'color': Colors.redAccent, 'desc': 'Engelli çocukların ve bireylerin rehabilitasyon merkezlerindeki destek eğitim giderleri, rapor şartıyla devlet tarafından karşılanır.'},
      {'title': 'Sınavlarda Ek Süre ve Yardımcı Hakkı', 'icon': Icons.timer, 'color': Colors.orangeAccent, 'desc': 'Merkezi sınavlarda engellilere ek süre verilir; ayrıca okuyucu veya işaretleyici desteği gibi kolaylıklar sağlanır.'},
      {'title': 'KYK Burs ve Yurt Önceliği', 'icon': Icons.apartment, 'color': Colors.brown, 'desc': 'Yükseköğrenim gören engelli öğrenciler, KYK yurtlarına yerleştirmede ve burs alımında doğrudan öncelik hakkına sahiptir.'},
      {'title': 'Üniversite Harç Muafiyeti', 'icon': Icons.money_off_csred, 'color': Colors.red, 'desc': 'Devlet üniversitelerinde eğitim gören engelli öğrencilerden üniversite harcı veya kayıt ücreti alınmaz.'},
      {'title': 'Müze ve Ören Yerlerine Ücretsiz Giriş', 'icon': Icons.museum, 'color': Colors.grey, 'desc': 'Kültür Bakanlığı\'na bağlı tüm müze, antik kent ve ören yerleri engellilere ve bir refakatçisine tamamen ücretsizdir.'},
      {'title': 'Devlet Tiyatroları İndirimi', 'icon': Icons.theater_comedy, 'color': Colors.deepOrange, 'desc': 'Engelli bireyler, devlet tiyatrolarındaki temsilleri ücretsiz veya çok düşük sembolik ücretlerle izleme hakkına sahiptir.'},
      {'title': 'Milli Parklara Ücretsiz Giriş', 'icon': Icons.park, 'color': Colors.green, 'desc': 'Orman Genel Müdürlüğü\'ne bağlı milli parklara ve mesire alanlarına engelli bireyleri taşıyan araçlarla giriş ücretsizdir.'},
      {'title': 'Su Faturası İndirimi', 'icon': Icons.water_drop, 'color': Colors.lightBlue, 'desc': 'Belediyelerin büyük çoğunluğu, engelli abonelerinin su faturalarında %50 oranında indirim uygulamaktadır.'},
      {'title': 'Hastanelerde Muayene Önceliği', 'icon': Icons.local_hospital, 'color': Colors.red, 'desc': 'Engelli bireyler, tüm sağlık kuruluşlarındaki poliklinik muayenelerinde yasal olarak öncelik hakkına sahiptir.'},
      {'title': 'Evde Sağlık Hizmeti', 'icon': Icons.home_repair_service, 'color': Colors.teal, 'desc': 'Hastaneye gidemeyecek durumda olan yatağa bağımlı engelliler için doktor, hemşire ve fizyoterapist eşliğinde evde sağlık hizmeti sunulur.'},
      {'title': 'Tıbbi Cihaz ve Malzeme Ödemesi', 'icon': Icons.medical_services, 'color': Colors.blueGrey, 'desc': 'Tekerlekli sandalye, ortez, protez, işitme cihazı ve hasta altı bezi gibi ihtiyaçların maliyeti SGK tarafından belirlenen limitlerle karşılanır.'},
      {'title': 'Engelli Aylığı (2022 Maaşı)', 'icon': Icons.account_balance_wallet, 'color': Colors.green, 'desc': 'Sosyal güvencesi olmayan ve hane içi kişi başı geliri asgari ücretin belirli bir oranının altında kalan engellilere ödenen aylık nakdi yardımdır.'},
      {'title': 'Evde Bakım Yardımı', 'icon': Icons.family_restroom, 'color': Colors.pink, 'desc': 'Ağır engelli bireyin bakımını üstlenen akrabasına, bakımın evde yapılması şartıyla her ay ödenen bakım ücretidir.'},
      {'title': 'GSM ve İnternet İndirimi', 'icon': Icons.wifi, 'color': Colors.blue, 'desc': 'Tüm GSM operatörleri ve internet servis sağlayıcıları, engelli müşterilerine özel %25 ile %40 arasında indirimli tarifeler sunar.'},
      {'title': 'Digiturk/D-Smart/TV+ İndirimleri', 'icon': Icons.tv, 'color': Colors.purple, 'desc': 'Ücretli televizyon platformları, engelli raporu beyan edildiğinde üyelik paketlerinde %50 indirim uygular.'},
      {'title': 'Vasiyetname ve Noter İşlemleri', 'icon': Icons.gavel, 'color': Colors.brown, 'desc': 'Görme ve işitme engellilerin noter işlemlerinde imza atamama durumunda iki şahit bulundurma hakkı ve bazı harç kolaylıkları mevcuttur.'},
      {'title': 'Korumalı İşyerleri', 'icon': Icons.security, 'color': Colors.indigo, 'desc': 'Zihinsel veya ruhsal engelli bireylerin istihdam edilmesi için devlet tarafından desteklenen, özel çalışma koşullarına sahip iş yerleridir.'},
      {'title': 'Belediye Sosyal Tesis İndirimi', 'icon': Icons.restaurant, 'color': Colors.orange, 'desc': 'Belediyelere bağlı sosyal tesislerde yemek, konaklama veya dinlenme hizmetlerinde engellilere özel indirimler uygulanır.'},
      {'title': 'Erişilebilirlik Düzenlemesi Talebi', 'icon': Icons.accessible, 'color': Colors.deepPurple, 'desc': 'Engelli bireyler, yaşadıkları çevrenin (kaldırım, asansör, rampa) engellerine uygun hale getirilmesi için belediyelere resmi başvuruda bulunma ve yaptırım talep etme hakkına sahiptir.'},
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
