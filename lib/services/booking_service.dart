import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking.dart';

class BookingService {
  final CollectionReference _bookingsCollection =
      FirebaseFirestore.instance.collection('bookings');

  Future<void> createBooking(Booking booking) async {
    await _bookingsCollection.add(booking.toMap());
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    final snapshot = await _bookingsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('dateTime', descending: false)
        .get();

    return snapshot.docs
        .map((doc) =>
            Booking.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    await _bookingsCollection.doc(bookingId).update({'status': newStatus});
  }

  Future<void> rescheduleBooking(String bookingId, DateTime newDateTime) async {
    await _bookingsCollection.doc(bookingId).update({'dateTime': newDateTime});
  }
}
