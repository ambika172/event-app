import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/local_storage_service.dart';

class BookingScreen extends StatefulWidget {
  final VoidCallback? onBookingConfirmed;

  /// Optional event name to pre-select on load, e.g. when arriving here
  /// via an event's "Book Now" button. Matched (case-insensitively)
  /// against [availableEvents]; ignored if no match is found.
  final String? initialEventName;

  const BookingScreen({super.key, this.onBookingConfirmed, this.initialEventName});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();

  EventInfo? _selectedEvent;
  final _userNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ticketsController = TextEditingController();
  DateTime? _bookingDate;
  String? _paymentMethod;

  static const double _serviceChargeRate = 0.05; // 5% service charge
  static const _paymentMethods = ['Credit Card', 'Debit Card', 'UPI', 'Cash'];

  @override
  void initState() {
    super.initState();
    final name = widget.initialEventName;
    if (name != null) {
      for (final e in availableEvents) {
        if (e.name.toLowerCase() == name.toLowerCase()) {
          _selectedEvent = e;
          break;
        }
      }
    }
  }

  double get _ticketCost {
    final qty = int.tryParse(_ticketsController.text) ?? 0;
    if (_selectedEvent == null) return 0;
    return qty * _selectedEvent!.ticketPrice;
  }

  double get _serviceCharge => _ticketCost * _serviceChargeRate;

  double get _grandTotal => _ticketCost + _serviceCharge;

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _ticketsController.dispose();
    super.dispose();
  }

  Future<void> _pickBookingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _bookingDate = picked);
    }
  }

  bool? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final regex = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(value.trim());
  }

  Future<void> _confirmBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedEvent == null) {
      _showError('Please select an event.');
      return;
    }
    if (_bookingDate == null) {
      _showError('Please choose a booking date.');
      return;
    }
    if (_paymentMethod == null) {
      _showError('A payment method must be selected before booking confirmation.');
      return;
    }

    final booking = Booking(
      bookingId: 'BK${DateTime.now().millisecondsSinceEpoch}',
      eventName: _selectedEvent!.name,
      userName: _userNameController.text.trim(),
      email: _emailController.text.trim(),
      numberOfTickets: int.parse(_ticketsController.text),
      bookingDate:
          '${_bookingDate!.day}/${_bookingDate!.month}/${_bookingDate!.year}',
      ticketCost: _ticketCost,
      serviceCharge: _serviceCharge,
      grandTotal: _grandTotal,
      paymentMethod: _paymentMethod!,
    );

    await LocalStorageService.addBooking(booking);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking confirmed successfully!')),
    );

    _formKey.currentState!.reset();
    setState(() {
      _selectedEvent = null;
      _bookingDate = null;
      _paymentMethod = null;
      _userNameController.clear();
      _emailController.clear();
      _ticketsController.clear();
    });

    widget.onBookingConfirmed?.call();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Event Booking',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Event Name
            DropdownButtonFormField<EventInfo>(
              value: _selectedEvent,
              decoration: const InputDecoration(
                labelText: 'Event Name',
                border: OutlineInputBorder(),
              ),
              items: availableEvents
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                            '${e.name} (₹${e.ticketPrice.toStringAsFixed(0)} • ${e.availableSeats} seats)'),
                      ))
                  .toList(),
              onChanged: (value) => setState(() {
                _selectedEvent = value;
                _ticketsController.clear();
              }),
              validator: (value) => value == null ? 'Please select an event' : null,
            ),
            const SizedBox(height: 12),

            // User Name
            TextFormField(
              controller: _userNameController,
              decoration: const InputDecoration(
                labelText: 'User Name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'User name is required' : null,
            ),
            const SizedBox(height: 12),

            // Email Address
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Email address cannot be empty';
                }
                if (_validateEmail(v) == false) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Number of Tickets
            TextFormField(
              controller: _ticketsController,
              decoration: const InputDecoration(
                labelText: 'Number of Tickets',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Number of tickets cannot be empty';
                }
                final qty = int.tryParse(v);
                if (qty == null || qty <= 0) {
                  return 'Number of tickets must be greater than zero';
                }
                if (_selectedEvent != null && qty > _selectedEvent!.availableSeats) {
                  return 'Cannot exceed ${_selectedEvent!.availableSeats} available seats';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Booking Date
            InkWell(
              onTap: _pickBookingDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Booking Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _bookingDate == null
                      ? 'Select a date'
                      : '${_bookingDate!.day}/${_bookingDate!.month}/${_bookingDate!.year}',
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Payment Method
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              items: _paymentMethods
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (value) => setState(() => _paymentMethod = value),
              validator: (value) =>
                  value == null ? 'A payment method must be selected' : null,
            ),
            const SizedBox(height: 20),

            // Price summary
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _priceRow('Ticket Cost', _ticketCost),
                    _priceRow('Service Charge (5%)', _serviceCharge),
                    const Divider(),
                    _priceRow('Grand Total', _grandTotal, bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _confirmBooking,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(14)),
                child: const Text('Confirm Booking'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, double value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('₹${value.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}
