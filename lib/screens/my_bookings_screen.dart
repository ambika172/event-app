import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/local_storage_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => MyBookingsScreenState();
}

class MyBookingsScreenState extends State<MyBookingsScreen> {
  List<Booking> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  /// Public so the parent tab controller can trigger a reload
  /// after a new booking is confirmed.
  Future<void> refresh() async {
    setState(() => _loading = true);
    final bookings = await LocalStorageService.getBookings();
    setState(() {
      _bookings = bookings;
      _loading = false;
    });
  }

  Future<void> _cancelBooking(Booking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Cancel booking for "${booking.eventName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await LocalStorageService.deleteBooking(booking.bookingId);
      await refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bookings.isEmpty) {
      return RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Center(child: Text('No bookings yet.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          booking.eventName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Chip(
                        label: Text(booking.status),
                        backgroundColor: booking.status == 'Confirmed'
                            ? Colors.green.shade100
                            : Colors.grey.shade300,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Booking ID: ${booking.bookingId}'),
                  Text('Booking Date: ${booking.bookingDate}'),
                  Text('Number of Tickets: ${booking.numberOfTickets}'),
                  Text(
                    'Total Amount: ₹${booking.grandTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelBooking(booking),
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      label: const Text('Cancel Booking',
                          style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
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
