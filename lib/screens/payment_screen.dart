import 'dart:math';
import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../models/booking.dart';
import '../services/local_storage_service.dart';
import 'booking_confirmation_screen.dart';

/// Payment step of the booking flow (merged in from the Smart Event
/// Management Platform's payment module). Reached from [BookingScreen]
/// once the event, attendee details, ticket count and date have been
/// validated. Handles method selection, card/UPI validation, computes the
/// service charge & grand total, "processes" the payment, then persists
/// the resulting [Booking] and hands off to [BookingConfirmationScreen].
class PaymentScreen extends StatefulWidget {
  final String eventName;
  final String userName;
  final String email;
  final int numberOfTickets;
  final double ticketAmount; // price per ticket
  final String bookingDate;
  final VoidCallback? onBookingConfirmed;

  const PaymentScreen({
    super.key,
    required this.eventName,
    required this.userName,
    required this.email,
    required this.numberOfTickets,
    required this.ticketAmount,
    required this.bookingDate,
    this.onBookingConfirmed,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();

  static const List<String> paymentMethods = [
    'Credit Card',
    'Debit Card',
    'UPI',
    'Net Banking',
    'Wallet',
  ];

  String? _selectedMethod;
  bool _isProcessing = false;

  final _cardNumberController = TextEditingController();
  final _cvvController = TextEditingController();
  final _expiryController = TextEditingController(); // MM/YY
  final _upiController = TextEditingController();

  static final RegExp _upiRegex = RegExp(r'^[\w.\-]{2,256}@[a-zA-Z]{2,64}$');

  double get subtotal => widget.numberOfTickets * widget.ticketAmount;

  double get serviceCharge =>
      double.parse((subtotal * 0.05).toStringAsFixed(2)); // 5% service charge

  double get grandTotal => subtotal + serviceCharge;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cvvController.dispose();
    _expiryController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  bool _isCardMethod(String? method) =>
      method == 'Credit Card' || method == 'Debit Card';

  String? _validateExpiry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Expiry date is required';
    }
    final regex = RegExp(r'^(0[1-9]|1[0-2])\/([0-9]{2})$');
    final match = regex.firstMatch(value.trim());
    if (match == null) {
      return 'Enter expiry as MM/YY';
    }
    final month = int.parse(match.group(1)!);
    final year = 2000 + int.parse(match.group(2)!);
    final expiryEnd = DateTime(year, month + 1, 1);
    final now = DateTime.now();
    if (expiryEnd.isBefore(DateTime(now.year, now.month, 1))) {
      return 'Expiry date cannot be earlier than the current date';
    }
    return null;
  }

  String _generateBookingId() {
    final rand = Random();
    final suffix = List.generate(6, (_) => rand.nextInt(10)).join();
    return 'BK${DateTime.now().year}$suffix';
  }

  Future<void> _submitPayment() async {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please select a payment method before proceeding.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate processing
    setState(() => _isProcessing = false);

    if (!mounted) return;

    final booking = Booking(
      bookingId: _generateBookingId(),
      eventName: widget.eventName,
      userName: widget.userName,
      email: widget.email,
      numberOfTickets: widget.numberOfTickets,
      bookingDate: widget.bookingDate,
      ticketCost: subtotal,
      serviceCharge: serviceCharge,
      grandTotal: grandTotal,
      paymentMethod: _selectedMethod!,
    );

    await LocalStorageService.addBooking(booking);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BookingConfirmationScreen(
          booking: booking,
          onDone: widget.onBookingConfirmed,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.dark,
      appBar: AppBar(title: const Text('Payment')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _readOnlyField('Event Name', widget.eventName),
                    const SizedBox(height: 12),
                    _readOnlyField('User Name', widget.userName),
                    const SizedBox(height: 12),
                    _readOnlyField('Email Address', widget.email),
                    const SizedBox(height: 12),
                    _readOnlyField(
                        'Number of Tickets', '${widget.numberOfTickets}'),
                    const SizedBox(height: 12),
                    _readOnlyField(
                        'Ticket Cost', '₹${subtotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 12),
                    _readOnlyField('Service Charge (5%)',
                        '₹${serviceCharge.toStringAsFixed(2)}'),
                    const Divider(color: AppTheme.textMuted, height: 24),
                    _readOnlyField(
                        'Grand Total', '₹${grandTotal.toStringAsFixed(2)}',
                        bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Payment Method',
                style: TextStyle(
                    color: AppTheme.textLight, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedMethod,
              dropdownColor: AppTheme.darkCard,
              style: const TextStyle(color: AppTheme.textLight),
              hint: const Text('Select a payment method',
                  style: TextStyle(color: AppTheme.textMuted)),
              items: paymentMethods
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedMethod = value),
              validator: (value) =>
                  value == null ? 'Payment method cannot be empty' : null,
            ),
            const SizedBox(height: 16),

            if (_isCardMethod(_selectedMethod)) ..._buildCardFields(),
            if (_selectedMethod == 'UPI') ..._buildUpiFields(),
            if (_selectedMethod == 'Net Banking' || _selectedMethod == 'Wallet')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'You will be redirected to complete your $_selectedMethod payment.',
                  style: const TextStyle(color: AppTheme.textMuted),
                ),
              ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.all(14),
                ),
                onPressed: _isProcessing ? null : _submitPayment,
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Pay Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCardFields() {
    return [
      const Text('Card Details',
          style: TextStyle(
              color: AppTheme.textLight, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextFormField(
        controller: _cardNumberController,
        style: const TextStyle(color: AppTheme.textLight),
        keyboardType: TextInputType.number,
        maxLength: 16,
        decoration: const InputDecoration(labelText: 'Card Number'),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Card number is required';
          }
          if (!RegExp(r'^\d{16}$').hasMatch(value.trim())) {
            return 'Card number must contain exactly 16 digits';
          }
          return null;
        },
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _cvvController,
        style: const TextStyle(color: AppTheme.textLight),
        keyboardType: TextInputType.number,
        maxLength: 3,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'CVV'),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'CVV is required';
          }
          if (!RegExp(r'^\d{3}$').hasMatch(value.trim())) {
            return 'CVV must contain exactly 3 digits';
          }
          return null;
        },
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _expiryController,
        style: const TextStyle(color: AppTheme.textLight),
        decoration: const InputDecoration(labelText: 'Expiry Date (MM/YY)'),
        validator: _validateExpiry,
      ),
      const SizedBox(height: 12),
    ];
  }

  List<Widget> _buildUpiFields() {
    return [
      const Text('UPI Details',
          style: TextStyle(
              color: AppTheme.textLight, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextFormField(
        controller: _upiController,
        style: const TextStyle(color: AppTheme.textLight),
        decoration: const InputDecoration(
          labelText: 'UPI ID',
          hintText: 'example@bank',
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'UPI ID cannot be empty';
          }
          if (!_upiRegex.hasMatch(value.trim())) {
            return 'Enter a valid UPI ID (e.g. name@bank)';
          }
          return null;
        },
      ),
      const SizedBox(height: 12),
    ];
  }

  Widget _readOnlyField(String label, String value, {bool bold = false}) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(color: AppTheme.textMuted)),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: AppTheme.textLight,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
