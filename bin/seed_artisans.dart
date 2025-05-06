import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:casaluxe/firebase_options.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> artisanList = List.generate(10, (index) {
    return {
      'name': 'Artisan ${index + 1}',
      'specialty': _getSpecialty(index),
      'phone': '+2335${index.toString().padLeft(8, '0')}',
      'email': 'artisan${index + 1}@example.com',
      'rating': (4 + (index % 10) * 0.1).clamp(3.5, 5.0),
      'totalReviews': (index * 3 + 5),
      'photoUrl': 'https://via.placeholder.com/150?text=Artisan+${index + 1}',
      'location': {
        'lat': 5.60 + (index * 0.001), // Simulate spread in Accra
        'lng': -0.18 + (index * 0.001),
      },
      'canContact': index == 0, // Only Artisan 1 is reachable
      'description':
          'Skilled ${_getSpecialty(index).toLowerCase()} with over ${(index % 10) + 1} years of experience.',
    };
  });

  for (final artisan in artisanList) {
    await firestore.collection('artisans').add(artisan);
  }

  print('Artisan seeding complete.');
}

String _getSpecialty(int i) {
  const specialties = [
    'Plumber',
    'Electrician',
    'Painter',
    'Carpenter',
    'Tiler',
    'Mason',
    'Cleaner',
    'AC Technician'
  ];
  return specialties[i % specialties.length];
}
