import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class SosMainPage extends StatelessWidget {
  const SosMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Gönüllü Sistemi'),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.sos, size: 100, color: Colors.red),
            const SizedBox(height: 32),
            const Text(
              'Lütfen Sisteme Giriş Amacınızı Seçin',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            
            // YARDIM İSTEYEN BUTONU
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SosActivePage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber, size: 32),
                  SizedBox(width: 12),
                  Text('ACİL YARDIM İSTE (SOS)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // GÖNÜLLÜ BUTONU
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SosVolunteerPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.volunteer_activism, size: 28),
                  SizedBox(width: 12),
                  Text('GÖNÜLLÜ OL / SİNYALLERİ DİNLE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// YARDIM İSTEYEN (SOS GÖNDEREN) SAYFASI
// ==========================================
class SosActivePage extends StatefulWidget {
  const SosActivePage({super.key});

  @override
  State<SosActivePage> createState() => _SosActivePageState();
}

class _SosActivePageState extends State<SosActivePage> with SingleTickerProviderStateMixin {
  final _supabase = Supabase.instance.client;
  bool _isSosActive = false;
  String? _signalId;
  late AnimationController _pulseController;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _startSos();
  }

  Future<void> _startSos() async {
    try {
      // 1. Konum İzni
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Konum izni reddedildi.');
      }
      
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      
      // 2. SOS Sinyalini Veritabanına Yaz
      final user = _supabase.auth.currentUser;
      final response = await _supabase.from('sos_signals').insert({
        'user_id': user?.id,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'status': 'active'
      }).select().single();
      
      _signalId = response['id'];
      
      setState(() {
        _isSosActive = true;
      });

      // 3. Yakındaki gönüllüleri bul ve bildirim at (Basit mesafe hesabı client-side)
      _notifyNearbyVolunteers(position.latitude, position.longitude);

      // 4. Konumu periyodik olarak güncelle (Opsiyonel, şimdilik sadece sabit SOS gönderimi yapıyoruz)
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _notifyNearbyVolunteers(double lat, double lng) async {
    try {
      // Aktif gönüllüleri çek
      final volunteers = await _supabase.from('sos_volunteers').select().eq('is_active', true);
      
      for (var vol in volunteers) {
        double volLat = vol['latitude'];
        double volLng = vol['longitude'];
        
        // Mesafe hesapla (metre)
        double distance = Geolocator.distanceBetween(lat, lng, volLat, volLng);
        
        // 2 km (2000 metre) içindeyse bildirim at
        if (distance <= 2000) {
          await _supabase.from('notifications').insert({
            'user_id': vol['user_id'],
            'title': 'ACİL: YAKININIZDA SOS SİNYALİ!',
            'message': 'Yaklaşık ${(distance).toStringAsFixed(0)} metre yakınınızda bir engelli birey acil yardım istiyor!',
            'type': 'sos_alert'
          });
        }
      }
    } catch (e) {
      debugPrint('Bildirim gönderilirken hata: $e');
    }
  }

  Future<void> _stopSos() async {
    if (_signalId != null) {
      await _supabase.from('sos_signals').update({'status': 'resolved'}).eq('id', _signalId);
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _locationTimer?.cancel();
    _stopSos(); // Ekrandan çıkılırsa SOS kapansın
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: Center(
          child: _isSosActive 
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.2),
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.white24, blurRadius: 40, spreadRadius: 20)
                      ]
                    ),
                    child: const Icon(Icons.sos, size: 100, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 48),
                const Text(
                  'SOS SİNYALİ GÖNDERİLİYOR',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Yakınınızdaki (2KM) gönüllülere bildirim gönderildi. Lütfen bulunduğunuz yerde bekleyin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 64),
                ElevatedButton.icon(
                  onPressed: _stopSos,
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: const Text('SOS İPTAL ET / KAPAT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                  ),
                )
              ],
            )
          : const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 20),
                Text('Konum alınıyor, lütfen bekleyin...', style: TextStyle(color: Colors.white))
              ],
            ),
        ),
      ),
    );
  }
}

// ==========================================
// GÖNÜLLÜ SAYFASI (DİNLEYİCİ)
// ==========================================
class SosVolunteerPage extends StatefulWidget {
  const SosVolunteerPage({super.key});

  @override
  State<SosVolunteerPage> createState() => _SosVolunteerPageState();
}

class _SosVolunteerPageState extends State<SosVolunteerPage> {
  final _supabase = Supabase.instance.client;
  bool _isListening = false;
  List<dynamic> _activeSignals = [];
  Timer? _refreshTimer;
  Position? _myPosition;

  @override
  void initState() {
    super.initState();
    _checkVolunteerStatus();
  }

  Future<void> _checkVolunteerStatus() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final data = await _supabase.from('sos_volunteers').select().eq('user_id', user.id).maybeSingle();
    if (data != null && data['is_active'] == true) {
      setState(() {
        _isListening = true;
      });
      _startListening();
    }
  }

  Future<void> _toggleListening() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    if (_isListening) {
      // Dinlemeyi Kapat
      await _supabase.from('sos_volunteers').upsert({
        'user_id': user.id,
        'is_active': false,
      });
      _refreshTimer?.cancel();
      setState(() {
        _isListening = false;
        _activeSignals = [];
      });
    } else {
      // Dinlemeyi Aç
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _myPosition = position;

      await _supabase.from('sos_volunteers').upsert({
        'user_id': user.id,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'is_active': true,
      });

      setState(() {
        _isListening = true;
      });
      _startListening();
    }
  }

  void _startListening() {
    _fetchSignals(); // İlk çekim
    // Her 5 saniyede bir sinyalleri güncelle
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchSignals();
    });
  }

  Future<void> _fetchSignals() async {
    if (!_isListening || _myPosition == null) return;

    try {
      final signals = await _supabase.from('sos_signals').select().eq('status', 'active');
      
      List<dynamic> nearbySignals = [];
      for (var sig in signals) {
        double dist = Geolocator.distanceBetween(_myPosition!.latitude, _myPosition!.longitude, sig['latitude'], sig['longitude']);
        if (dist <= 2000) { // Sadece 2KM içindekiler
          sig['distance'] = dist;
          nearbySignals.add(sig);
        }
      }

      // Mesafeye göre sırala (En yakın en üstte)
      nearbySignals.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

      if (mounted) {
        setState(() {
          _activeSignals = nearbySignals;
        });
      }
    } catch (e) {
      debugPrint('Sinyaller çekilemedi: $e');
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gönüllü Paneli'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.green.shade50,
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isListening ? 'Sinyaller Dinleniyor' : 'Gönüllü Modu Kapalı',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _isListening ? Colors.green.shade700 : Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isListening 
                          ? 'Şu anda 2 km çevrenizdeki SOS sinyalleri taranıyor. Acil durumlarda aşağıda belirecektir.'
                          : 'Yakınınızdaki engelli bireylere yardım etmek için gönüllü modunu aktifleştirin.',
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isListening,
                  activeColor: Colors.green,
                  onChanged: (val) => _toggleListening(),
                )
              ],
            ),
          ),
          
          Expanded(
            child: !_isListening 
              ? const Center(child: Text('Aktif sinyalleri görmek için dinlemeyi başlatın.', style: TextStyle(color: Colors.grey)))
              : _activeSignals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.radar, size: 80, color: Colors.green.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        const Text('Çevrenizde aktif SOS sinyali yok.', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _activeSignals.length,
                    itemBuilder: (context, index) {
                      final sig = _activeSignals[index];
                      final dist = sig['distance'] as double;
                      final lat = sig['latitude'];
                      final lng = sig['longitude'];

                      return Card(
                        color: Colors.red.shade50,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: Colors.red, child: Icon(Icons.warning, color: Colors.white)),
                          title: Text('ACİL YARDIM TALEBİ', style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold)),
                          subtitle: Text('Uzaklık: ${dist.toStringAsFixed(0)} metre yakınınızda!'),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              }
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            child: const Text('HARİTADA AÇ'),
                          ),
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}
