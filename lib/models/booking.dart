class Booking {
  final String bookingId;
  final String eventName;
  final String userName;
  final String email;
  final int numberOfTickets;
  final String bookingDate;
  final double ticketCost;
  final double serviceCharge;
  final double grandTotal;
  final String paymentMethod;
  String status;

  Booking({
    required this.bookingId,
    required this.eventName,
    required this.userName,
    required this.email,
    required this.numberOfTickets,
    required this.bookingDate,
    required this.ticketCost,
    required this.serviceCharge,
    required this.grandTotal,
    required this.paymentMethod,
    this.status = 'Confirmed',
  });

  Map<String, dynamic> toJson() => {
        'bookingId': bookingId,
        'eventName': eventName,
        'userName': userName,
        'email': email,
        'numberOfTickets': numberOfTickets,
        'bookingDate': bookingDate,
        'ticketCost': ticketCost,
        'serviceCharge': serviceCharge,
        'grandTotal': grandTotal,
        'paymentMethod': paymentMethod,
        'status': status,
      };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        bookingId: json['bookingId'],
        eventName: json['eventName'],
        userName: json['userName'],
        email: json['email'],
        numberOfTickets: json['numberOfTickets'],
        bookingDate: json['bookingDate'],
        ticketCost: (json['ticketCost'] as num).toDouble(),
        serviceCharge: (json['serviceCharge'] as num).toDouble(),
        grandTotal: (json['grandTotal'] as num).toDouble(),
        paymentMethod: json['paymentMethod'],
        status: json['status'] ?? 'Confirmed',
      );
}

/// Simple in-memory catalog of events used to drive price & seat validation.
class EventInfo {
  final String name;
  final double ticketPrice;
  final int availableSeats;

  const EventInfo({
    required this.name,
    required this.ticketPrice,
    required this.availableSeats,
  });
}

const List<EventInfo> availableEvents = [
  EventInfo(name: 'Tech Conference 2026', ticketPrice: 1500, availableSeats: 120),
  EventInfo(name: 'Music Festival', ticketPrice: 2500, availableSeats: 300),
  EventInfo(name: 'Startup Meetup', ticketPrice: 500, availableSeats: 60),
  EventInfo(name: 'Art Exhibition', ticketPrice: 300, availableSeats: 90),
];
