/// A single entry in the favorite history log (kept even after an event is
/// un-favorited, so it doubles as a "Favorite History" audit trail).
/// Merged in from the Day 5 (day5_app) Favorites module.
class FavoriteHistoryEntry {
  final String eventId;
  final String eventName;
  final String action; // 'added' | 'removed'
  final DateTime timestamp;

  FavoriteHistoryEntry({
    required this.eventId,
    required this.eventName,
    required this.action,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'eventName': eventName,
        'action': action,
        'timestamp': timestamp.toIso8601String(),
      };

  factory FavoriteHistoryEntry.fromJson(Map<String, dynamic> json) =>
      FavoriteHistoryEntry(
        eventId: json['eventId'],
        eventName: json['eventName'],
        action: json['action'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}
