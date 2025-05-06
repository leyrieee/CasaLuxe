import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String artisanCategory;
  final DateTime dateTime;
  final String status; // e.g. 'pending', 'confirmed', 'cancelled'

  Booking({
    required this.id,
    required this.userId,
    required this.artisanCategory,
    required this.dateTime,
    required this.status,
  });

  factory Booking.fromMap(Map<String, dynamic> data, String documentId) {
    return Booking(
      id: documentId,
      userId: data['userId'],
      artisanCategory: data['artisanCategory'],
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      status: data['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'artisanCategory': artisanCategory,
      'dateTime': dateTime,
      'status': status,
    };
  }
}
