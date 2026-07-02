import 'package:flutter/material.dart';
import 'booking_screen.dart';
import 'my_bookings_screen.dart';

/// Unified interface for the Booking Management System:
/// lets the user add new bookings and view/cancel existing ones.
///
/// [initialEventName] optionally pre-selects an event on the "New Booking"
/// tab (used when arriving here via an event's "Book Now" button).
class BookingManagementScreen extends StatefulWidget {
  final String? initialEventName;

  const BookingManagementScreen({super.key, this.initialEventName});

  @override
  State<BookingManagementScreen> createState() =>
      _BookingManagementScreenState();
}

class _BookingManagementScreenState extends State<BookingManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<MyBookingsScreenState> _myBookingsKey =
      GlobalKey<MyBookingsScreenState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add_circle_outline), text: 'New Booking'),
            Tab(icon: Icon(Icons.list_alt), text: 'My Bookings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BookingScreen(
            initialEventName: widget.initialEventName,
            onBookingConfirmed: () {
              _myBookingsKey.currentState?.refresh();
              _tabController.animateTo(1);
            },
          ),
          MyBookingsScreen(key: _myBookingsKey),
        ],
      ),
    );
  }
}
