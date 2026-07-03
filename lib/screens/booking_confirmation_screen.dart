import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../models/booking.dart';

/// Final step of the booking flow (merged in from the Smart Event
/// Management Platform's booking-confirmation module). Shown after
/// [PaymentScreen] has successfully "processed" payment and the booking
/// has been persisted locally.
class BookingConfirmationScreen extends StatelessWidget {
  final Booking booking;

  /// Invoked when the user leaves this screen (e.g. to refresh & switch
  /// to the "My Bookings" tab back in [BookingManagementScreen]).
  final VoidCallback? onDone;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
    this.onDone,
  });

  void _downloadTicket(BuildContext context) {
    // Stub: wire this up to your actual PDF/ticket generation service.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ticket for ${booking.bookingId} is downloading...')),
    );
  }

  void _finish(BuildContext context) {
    // Navigation stack at this point is [..., BookingManagementScreen,
    // BookingConfirmationScreen] (PaymentScreen was pushReplaced by this
    // screen), so a single pop returns to BookingManagementScreen.
    onDone?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark,
      appBar: AppBar(title: const Text('Booking Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: AppTheme.accent, size: 72),
            const SizedBox(height: 12),
            const Text(
              'Booking Successful!',
              style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow('Booking ID', booking.bookingId),
                    _infoRow('Event Name', booking.eventName),
                    _infoRow('Booking Date', booking.bookingDate),
                    _infoRow('Number of Tickets', '${booking.numberOfTickets}'),
                    _infoRow('Total Amount', '₹${booking.grandTotal.toStringAsFixed(2)}'),
                    _infoRow('Payment Method', booking.paymentMethod),
                    _infoRow('Booking Status', booking.status, bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.all(14),
                ),
                onPressed: () => _downloadTicket(context),
                icon: const Icon(Icons.download),
                label: const Text('Download Ticket'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                  side: const BorderSide(color: AppTheme.primary),
                ),
                onPressed: () => _finish(context),
                child: const Text('Back to My Bookings',
                    style: TextStyle(color: AppTheme.textLight)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(color: AppTheme.textMuted)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppTheme.textLight,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
