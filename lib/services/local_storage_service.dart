import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';
import '../models/favorite.dart';
import '../models/review.dart';

/// Centralized helper for everything the app persists locally:
/// - Logged-in user details & login status
/// - Booked events / booking history
/// - Favorite events & favorite history (merged from day5_app)
/// - Event reviews & ratings (merged from day5_app)
class LocalStorageService {
  static const _kIsLoggedIn = 'isLoggedIn';
  static const _kUserName = 'loggedInUserName';
  static const _kUserEmail = 'loggedInUserEmail';
  static const _kBookings = 'bookingHistory';
  static const _kFavoriteIds = 'favoriteEventIds';
  static const _kFavoriteHistory = 'favoriteHistory';
  static const _kReviews = 'eventReviews';

  // ---------------- User session ----------------

  static Future<void> saveLoginSession(String name, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsLoggedIn, true);
    await prefs.setString(_kUserName, name);
    await prefs.setString(_kUserEmail, email);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kIsLoggedIn) ?? false;
  }

  static Future<String?> getLoggedInUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserName);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsLoggedIn, false);
  }

  // ---------------- Bookings ----------------

  static Future<List<Booking>> getBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kBookings) ?? [];
    return raw.map((s) => Booking.fromJson(jsonDecode(s))).toList();
  }

  static Future<void> addBooking(Booking booking) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kBookings) ?? [];
    raw.add(jsonEncode(booking.toJson()));
    await prefs.setStringList(_kBookings, raw);
  }

  static Future<void> deleteBooking(String bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kBookings) ?? [];
    raw.removeWhere((s) => jsonDecode(s)['bookingId'] == bookingId);
    await prefs.setStringList(_kBookings, raw);
  }

  // ---------------- Favorites (merged from day5_app) ----------------

  static Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_kFavoriteIds) ?? const []).toSet();
  }

  static Future<void> _saveFavoriteIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kFavoriteIds, ids.toList());
  }

  static Future<List<FavoriteHistoryEntry>> getFavoriteHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kFavoriteHistory) ?? const [];
    final entries =
        raw.map((s) => FavoriteHistoryEntry.fromJson(jsonDecode(s))).toList();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  static Future<void> _appendFavoriteHistory(
      FavoriteHistoryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kFavoriteHistory) ?? [];
    raw.add(jsonEncode(entry.toJson()));
    await prefs.setStringList(_kFavoriteHistory, raw);
  }

  static Future<Set<String>> addFavorite(
      String eventId, String eventName) async {
    final ids = await getFavoriteIds();
    ids.add(eventId);
    await _saveFavoriteIds(ids);
    await _appendFavoriteHistory(FavoriteHistoryEntry(
      eventId: eventId,
      eventName: eventName,
      action: 'added',
      timestamp: DateTime.now(),
    ));
    return ids;
  }

  static Future<Set<String>> removeFavorite(
      String eventId, String eventName) async {
    final ids = await getFavoriteIds();
    ids.remove(eventId);
    await _saveFavoriteIds(ids);
    await _appendFavoriteHistory(FavoriteHistoryEntry(
      eventId: eventId,
      eventName: eventName,
      action: 'removed',
      timestamp: DateTime.now(),
    ));
    return ids;
  }

  // ---------------- Reviews & Ratings (merged from day5_app) ----------------

  static Future<List<Review>> getReviews() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kReviews) ?? const [];
    final reviews = raw.map((s) => Review.fromJson(jsonDecode(s))).toList();
    reviews.sort((a, b) => b.date.compareTo(a.date));
    return reviews;
  }

  static Future<void> _saveAllReviews(List<Review> reviews) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        _kReviews, reviews.map((r) => jsonEncode(r.toJson())).toList());
  }

  static Future<void> upsertReview(Review review) async {
    final reviews = await getReviews();
    final index = reviews.indexWhere((r) => r.id == review.id);
    if (index >= 0) {
      reviews[index] = review;
    } else {
      reviews.add(review);
    }
    await _saveAllReviews(reviews);
  }

  static Future<void> deleteReview(String reviewId) async {
    final reviews = await getReviews();
    reviews.removeWhere((r) => r.id == reviewId);
    await _saveAllReviews(reviews);
  }
}
