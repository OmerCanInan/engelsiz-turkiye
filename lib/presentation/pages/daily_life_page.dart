import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/repositories/report_repository.dart';

class DailyLifePage extends StatefulWidget {
  const DailyLifePage({super.key});

  @override
  State<DailyLifePage> createState() => _DailyLifePageState();
}

class _DailyLifePageState extends State<DailyLifePage> {
  GoogleMapController? _mapController;
  final _repository = ReportRepository();
  Set<Marker> _markers = {};
  LatLng _initialPosition = const LatLng(39.9334, 32.8597); // Ankara varsayılan

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadReports();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLng(_initialPosition));
    });
  }

  Future<void> _loadReports() async {
    try {
      final reports = await _repository.getReports();
      setState(() {
        _markers = reports.map((r) => Marker(
          markerId: MarkerId(r.id),
          position: r.location,
          infoWindow: InfoWindow(title: r.title, snippet: r.category),
        )).toSet();
      });
    } catch (e) {
      print('Hata: $e');
    }
  }

  void _onLongPress(LatLng pos) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ReportForm(location: pos, onSaved: _loadReports),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Engelsiz Şehir Haritası')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 14),
        onMapCreated: (c) => _mapController = c,
        markers: _markers,
        onLongPress: _onLongPress,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _getCurrentLocation(),
        label: const Text('Sorun Bildir (Uzun Bas)'),
        icon: const Icon(Icons.report_problem),
      ),
    );
  }
}

class _ReportForm extends StatefulWidget {
  final LatLng location;
  final VoidCallback onSaved;

  const _ReportForm({required this.location, required this.onSaved});

  @override
  State<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<_ReportForm> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'yol_bozuklugu';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Sorun Bildirimi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Başlık (Örn: Bozuk Rampa)')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            items: const [
              DropdownMenuItem(value: 'yol_bozuklugu', child: Text('Yol Bozukluğu')),
              DropdownMenuItem(value: 'rampa_eksikligi', child: Text('Rampa Eksikliği')),
              DropdownMenuItem(value: 'asansor_arizasi', child: Text('Asansör Arızası')),
            ],
            onChanged: (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 12),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: 'Açıklama')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await ReportRepository().createReport(
                title: _titleController.text,
                description: _descController.text,
                category: _category,
                location: widget.location,
              );
              Navigator.pop(context);
              widget.onSaved();
            },
            child: const Text('KAYDET'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
