/// Review model for the Event Review & Rating module.
/// Merged in from the Day 5 (day5_app) build and adapted to work against
/// the main app's real [Event] catalog instead of mock data.
class Review {
  final String id;
  final String bookingId;
  final String eventName;
  final String userName;
  final int rating; // 1-5
  final String title;
  final String description;
  final DateTime date;

  Review({
    required this.id,
    required this.bookingId,
    required this.eventName,
    required this.userName,
    required this.rating,
    required this.title,
    required this.description,
    required this.date,
  });

  Review copyWith({
    String? bookingId,
    String? eventName,
    String? userName,
    int? rating,
    String? title,
    String? description,
    DateTime? date,
  }) {
    return Review(
      id: id,
      bookingId: bookingId ?? this.bookingId,
      eventName: eventName ?? this.eventName,
      userName: userName ?? this.userName,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookingId': bookingId,
        'eventName': eventName,
        'userName': userName,
        'rating': rating,
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
      };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'],
        bookingId: json['bookingId'],
        eventName: json['eventName'],
        userName: json['userName'],
        rating: json['rating'],
        title: json['title'],
        description: json['description'],
        date: DateTime.parse(json['date']),
      );
}
