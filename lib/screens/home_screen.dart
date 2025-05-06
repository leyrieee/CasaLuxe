// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../app_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController _mapController;
  LatLng _currentPosition = const LatLng(5.6651, -0.1657); // Default: Accra
  bool _showMap = false;
  final Map<MarkerId, Marker> _markers = {};
  final List<String> categories = [
    'Plumber',
    'Electrician',
    'Cleaner',
    'Laundry',
    'Handyman'
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _generateMockArtisans();
      });
    }
  }

  void _generateMockArtisans() {
    final random = Random();
    for (int i = 0; i < categories.length; i++) {
      final offsetLat = (random.nextDouble() - 0.5) / 500; // ~0.001 offset
      final offsetLng = (random.nextDouble() - 0.5) / 500;
      final artisanPosition = LatLng(_currentPosition.latitude + offsetLat,
          _currentPosition.longitude + offsetLng);
      final markerId = MarkerId('artisan_$i');
      final category = categories[i];
      _markers[markerId] = Marker(
        markerId: markerId,
        position: artisanPosition,
        infoWindow: InfoWindow(
          title: 'Artisan $category',
          snippet: 'Tap to chat or book',
          onTap: () => _showArtisanBottomSheet(category),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    }
    setState(() {});
  }

  void _showArtisanBottomSheet(String category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Artisan $category',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Professional $category near you',
                style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Opening chat with Artisan $category')));
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Booking Artisan $category')));
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Book'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          if (_showMap)
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition,
                  zoom: 15,
                ),
                onMapCreated: (controller) => _mapController = controller,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                markers: Set<Marker>.of(_markers.values),
              ),
            ),
          SafeArea(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              margin: _showMap
                  ? const EdgeInsets.only(top: 250)
                  : const EdgeInsets.only(top: 0),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: _showMap
                    ? const BorderRadius.vertical(top: Radius.circular(20))
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Find trusted help nearby',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(_showMap ? Icons.close : Icons.map),
                        onPressed: () => setState(() => _showMap = !_showMap),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText:
                          'Search for services... Plumber, Electrician...',
                      hintStyle: GoogleFonts.poppins(fontSize: 14),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          categories.map((c) => _buildQuickTile(c)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickTile(String label) {
    final icons = {
      'Plumber': Icons.plumbing,
      'Electrician': Icons.electrical_services,
      'Cleaner': Icons.cleaning_services,
      'Laundry': Icons.local_laundry_service,
      'Handyman': Icons.handyman,
    };

    return GestureDetector(
      onTap: () => _showArtisanBottomSheet(label),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        width: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icons[label] ?? Icons.person,
                size: 30, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
