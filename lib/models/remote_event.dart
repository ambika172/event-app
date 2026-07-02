// Kept from the original "smart_event_app" project as an alternate,
// JSON-driven data model (see assets/events.json). The app currently runs
// on the simpler `Event` model in event.dart, but this remains available
// for a future switch to remote/JSON-backed event data.
class RemoteScheduleItem {
  final String time;
  final String activity;

  RemoteScheduleItem({required this.time, required this.activity});

  factory RemoteScheduleItem.fromJson(Map<String, dynamic> json) {
    return RemoteScheduleItem(
      time: json['time'],
      activity: json['activity'],
    );
  }
}

class RemoteEvent {
  final String id;
  final String eventName;
  final String category;
  final String organizer;
  final String date;
  final String time;
  final String location;
  final double ticketPrice;
  final double rating;
  final String image;
  final String shortDescription;
  final String fullDescription;
  final String venueDetails;
  final String organizerInformation;
  final int availableSeats;
  final List<RemoteScheduleItem> eventSchedule;
  final List<String> photoGallery;
  final String locationMap;

  RemoteEvent({
    required this.id,
    required this.eventName,
    required this.category,
    required this.organizer,
    required this.date,
    required this.time,
    required this.location,
    required this.ticketPrice,
    required this.rating,
    required this.image,
    required this.shortDescription,
    required this.fullDescription,
    required this.venueDetails,
    required this.organizerInformation,
    required this.availableSeats,
    required this.eventSchedule,
    required this.photoGallery,
    required this.locationMap,
  });

  factory RemoteEvent.fromJson(Map<String, dynamic> json) {
    return RemoteEvent(
      id: json['id'],
      eventName: json['eventName'],
      category: json['category'],
      organizer: json['organizer'],
      date: json['date'],
      time: json['time'],
      location: json['location'],
      ticketPrice: (json['ticketPrice'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      image: json['image'],
      shortDescription: json['shortDescription'],
      fullDescription: json['fullDescription'],
      venueDetails: json['venueDetails'],
      organizerInformation: json['organizerInformation'],
      availableSeats: json['availableSeats'],
      eventSchedule: (json['eventSchedule'] as List)
          .map((e) => RemoteScheduleItem.fromJson(e))
          .toList(),
      photoGallery: List<String>.from(json['photoGallery']),
      locationMap: json['locationMap'],
    );
  }
}
