// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../screens/chat_screen.dart';
import '../screens/booking_form_screen.dart';
import '../app_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ignore: unused_field
  late GoogleMapController _mapController;
  LatLng _currentPosition = const LatLng(5.6651, -0.1657);
  bool _showMap = false;
  final Map<MarkerId, Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  final List<String> categories = [
    'Plumber',
    'Electrician',
    'Cleaner',
    'Laundry',
    'Handyman'
  ];
  List<Map<String, dynamic>> _displayedArtisans = [];

  final List<Map<String, dynamic>> allArtisans = List.generate(30, (index) {
    final names = [
      'AquaFix Services',
      'VoltPro Electric',
      'SparkleClean Co.',
      'FreshPress Laundry',
      'FixIt Hub',
      'PipeMasters',
      'WiredRight Solutions',
      'EcoClean Express',
      'UrbanWash',
      'QuickFix Crew',
      'LeakAway',
      'BrightCurrent',
      'NeatNest Cleaners',
      'WashPro Laundry',
      'Reliable Repairs',
      'BlueTap Plumbing',
      'PowerNode Electricians',
      'ShinySpaces',
      'LaundryLux',
      'HandyGuys Inc.',
      'DrainWizards',
      'CircuitSquad',
      'Spick&Span',
      'SpeedyWash',
      'MasterHand Repairs',
      'FlowLine Plumbers',
      'AmpedUp Electrics',
      'GlowUp Cleaners',
      'EcoBubble Laundry',
      'HandyHome Pros',
    ];
    final categories = [
      'Plumber',
      'Electrician',
      'Cleaner',
      'Laundry',
      'Handyman'
    ];
    final random = Random();
    return {
      'name': names[index],
      'category': categories[index % categories.length],
      'distance':
          (random.nextDouble() * 10 + 0.5).toStringAsFixed(1), // 0.5km–10.5km
      'rating': (4 + random.nextDouble()).toStringAsFixed(1), // 4.0–5.0
    };
  });

  @override
  void initState() {
    super.initState();
    _displayedArtisans = List.from(allArtisans);
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
        _generateMockMarkers();
      });
    }
  }

  void _generateMockMarkers() {
    _markers.clear();
    final random = Random();
    for (int i = 0; i < _displayedArtisans.length; i++) {
      final offsetLat = (random.nextDouble() - 0.5) / 300;
      final offsetLng = (random.nextDouble() - 0.5) / 300;
      final position = LatLng(_currentPosition.latitude + offsetLat,
          _currentPosition.longitude + offsetLng);
      final artisan = _displayedArtisans[i];
      final markerId = MarkerId('artisan_$i');
      _markers[markerId] = Marker(
        markerId: markerId,
        position: position,
        infoWindow: InfoWindow(
          title: artisan['name'],
          snippet: 'Tap to chat or book',
          onTap: () =>
              _showArtisanBottomSheet(artisan['name'], artisan['category']),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    }
    setState(() {});
  }

  void _filterArtisans(String query) {
    final filtered = allArtisans.where((artisan) {
      final name = artisan['name'].toLowerCase();
      final category = artisan['category'].toLowerCase();
      return name.contains(query.toLowerCase()) ||
          category.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _displayedArtisans = filtered;
      _generateMockMarkers();
    });
  }

  Future<void> _startChatWithArtisan(String name) async {
    final client = StreamChat.of(context).client;
    final user = client.state.currentUser;
    if (user == null) return;

    final channel = client.channel(
      'messaging',
      id: '${user.id}_${name.replaceAll(' ', '').toLowerCase()}',
      extraData: {
        'members': [user.id, 'admin'],
        'name': 'Chat with $name'
      },
    );
    await channel.watch();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(channelId: channel.id!, artisanName: name),
      ),
    );
  }

  void _showArtisanBottomSheet(String name, String category) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name,
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Professional $category service',
                style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _startChatWithArtisan(name);
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BookingFormScreen(artisanCategory: category),
                      ),
                    );
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

  Widget _buildQuickTile(String label) {
    final icons = {
      'Plumber': Icons.plumbing,
      'Electrician': Icons.electrical_services,
      'Cleaner': Icons.cleaning_services,
      'Laundry': Icons.local_laundry_service,
      'Handyman': Icons.handyman,
    };

    return GestureDetector(
      onTap: () => _showArtisanBottomSheet('Top $label Service', label),
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
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icons[label] ?? Icons.person,
                size: 30, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
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
                initialCameraPosition:
                    CameraPosition(target: _currentPosition, zoom: 15),
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Find trusted help nearby',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          )),
                      IconButton(
                        icon: Icon(_showMap ? Icons.close : Icons.map),
                        onPressed: () => setState(() => _showMap = !_showMap),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    onChanged: _filterArtisans,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Search for services or names...',
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
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          categories.map((c) => _buildQuickTile(c)).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _displayedArtisans.length,
                      itemBuilder: (context, index) {
                        final artisan = _displayedArtisans[index];
                        return ListTile(
                          title: Text(artisan['name'],
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              '${artisan['category']} • ${artisan['distance']} km • ⭐ ${artisan['rating']}',
                              style: GoogleFonts.poppins(fontSize: 13)),
                          trailing: Icon(Icons.chevron_right,
                              color: AppColors.primary),
                          onTap: () => _showArtisanBottomSheet(
                              artisan['name'], artisan['category']),
                        );
                      },
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
}
