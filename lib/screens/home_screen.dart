// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import '../screens/chat_screen.dart';
import '../app_config.dart';
import '../screens/booking_form_screen.dart';

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

  final List<Map<String, dynamic>> allArtisans = [
    {
      "name": "AquaFix Services",
      "category": "Handyman",
      "rating": 4.6,
      "distance": 1.0
    },
    {
      "name": "VoltPro Electric",
      "category": "Electrician",
      "rating": 4.1,
      "distance": 0.4
    },
    {
      "name": "SparkleClean Co.",
      "category": "Cleaner",
      "rating": 5.0,
      "distance": 0.6
    },
    {
      "name": "FreshPress Laundry",
      "category": "Laundry",
      "rating": 3.9,
      "distance": 1.0
    },
    {
      "name": "FixIt Hub",
      "category": "Handyman",
      "rating": 4.2,
      "distance": 1.5
    },
    {
      "name": "PipeMasters",
      "category": "Plumber",
      "rating": 4.2,
      "distance": 2.9
    },
    {
      "name": "WiredRight Solutions",
      "category": "Electrician",
      "rating": 4.6,
      "distance": 2.5
    },
    {
      "name": "EcoClean Express",
      "category": "Cleaner",
      "rating": 4.4,
      "distance": 2.7
    },
    {
      "name": "UrbanWash",
      "category": "Laundry",
      "rating": 4.8,
      "distance": 2.6
    },
    {
      "name": "QuickFix Crew",
      "category": "Handyman",
      "rating": 5.0,
      "distance": 1.6
    },
    {"name": "LeakAway", "category": "Plumber", "rating": 4.5, "distance": 2.7},
    {
      "name": "BrightCurrent",
      "category": "Electrician",
      "rating": 4.2,
      "distance": 1.9
    },
    {
      "name": "NeatNest Cleaners",
      "category": "Cleaner",
      "rating": 4.5,
      "distance": 2.9
    },
    {
      "name": "WashPro Laundry",
      "category": "Laundry",
      "rating": 4.4,
      "distance": 2.8
    },
    {
      "name": "Reliable Repairs",
      "category": "Handyman",
      "rating": 4.0,
      "distance": 1.9
    },
    {
      "name": "BlueTap Plumbing",
      "category": "Plumber",
      "rating": 4.2,
      "distance": 2.2
    },
    {
      "name": "PowerNode Electricians",
      "category": "Electrician",
      "rating": 4.6,
      "distance": 2.4
    },
    {
      "name": "ShinySpaces",
      "category": "Cleaner",
      "rating": 4.4,
      "distance": 2.9
    },
    {
      "name": "LaundryLux",
      "category": "Laundry",
      "rating": 3.8,
      "distance": 1.7
    },
    {
      "name": "HandyGuys Inc.",
      "category": "Handyman",
      "rating": 4.1,
      "distance": 2.1
    },
    {
      "name": "DrainWizards",
      "category": "Plumber",
      "rating": 4.5,
      "distance": 1.8
    },
    {
      "name": "CircuitSquad",
      "category": "Electrician",
      "rating": 4.0,
      "distance": 2.4
    },
    {
      "name": "Spick&Span",
      "category": "Cleaner",
      "rating": 3.8,
      "distance": 1.8
    },
    {
      "name": "SpeedyWash",
      "category": "Laundry",
      "rating": 4.4,
      "distance": 1.7
    },
    {
      "name": "MasterHand Repairs",
      "category": "Handyman",
      "rating": 3.8,
      "distance": 1.8
    },
    {
      "name": "FlowLine Plumbers",
      "category": "Plumber",
      "rating": 3.6,
      "distance": 2.8
    },
    {
      "name": "AmpedUp Electrics",
      "category": "Electrician",
      "rating": 4.3,
      "distance": 2.3
    },
    {
      "name": "GlowUp Cleaners",
      "category": "Cleaner",
      "rating": 4.9,
      "distance": 2.1
    },
    {
      "name": "EcoBubble Laundry",
      "category": "Laundry",
      "rating": 3.7,
      "distance": 2.7
    },
    {
      "name": "HandyHome Pros",
      "category": "Handyman",
      "rating": 4.2,
      "distance": 2.9
    }
  ];

  List<Map<String, dynamic>> _displayedArtisans = [];

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
        _generateMarkers();
      });
    }
  }

  void _generateMarkers() {
    final random = Random();
    _markers.clear();
    for (int i = 0; i < _displayedArtisans.length; i++) {
      final offsetLat = (random.nextDouble() - 0.5) / 300;
      final offsetLng = (random.nextDouble() - 0.5) / 300;
      final position = LatLng(
        _currentPosition.latitude + offsetLat,
        _currentPosition.longitude + offsetLng,
      );

      final artisan = _displayedArtisans[i];
      final markerId = MarkerId('artisan_$i');
      _markers[markerId] = Marker(
        markerId: markerId,
        position: position,
        infoWindow: InfoWindow(
          title: artisan['name'],
          snippet: 'Tap to chat or book',
          onTap: () => _showArtisanBottomSheet(artisan),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      );
    }
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
      _generateMarkers();
    });
  }

  void _showArtisanBottomSheet(Map<String, dynamic> artisan) {
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
            Text(artisan['name'],
                style: GoogleFonts.playfairDisplay(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Professional ${artisan['category']} service',
                style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(height: 10),
            Text('★ ${artisan['rating']} · ${artisan['distance']} km away',
                style:
                    GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _startChatWithArtisan(artisan['name']);
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
                        builder: (_) => BookingFormScreen(
                          artisanCategory: artisan['category'],
                        ),
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

  Future<void> _startChatWithArtisan(String name) async {
    final client = StreamChat.of(context).client;
    final user = client.state.currentUser;
    if (user == null) return;

    final channel = client.channel(
      'messaging',
      id: '${user.id}${name.replaceAll(' ', '').toLowerCase()}',
      extraData: {
        'members': [user.id, 'admin'],
        'name': 'Chat with $name',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              color: AppColors.primary)),
                      IconButton(
                        icon: Icon(_showMap ? Icons.close : Icons.map),
                        onPressed: () => setState(() => _showMap = !_showMap),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children:
                          categories.map((c) => _buildQuickTile(c)).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._displayedArtisans.map((artisan) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(artisan['name'],
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              '${artisan['category']} • ★${artisan['rating']} • ${artisan['distance']}km',
                              style: GoogleFonts.poppins(fontSize: 12)),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showArtisanBottomSheet(artisan),
                        ),
                      )),
                ],
              ),
            ),
          ),
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
      onTap: () => _showArtisanBottomSheet(
          {'name': 'Top $label Service', 'category': label}),
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
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
