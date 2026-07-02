import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking.dart';

/// Centralized helper for everything the app persists locally:
/// - Logged-in user details & login status
/// - Booked events / booking history
class LocalStorageService {
  static const _kIsLoggedIn = 'isLoggedIn';
  static const _kUserName = 'loggedInUserName';
  static const _kUserEmail = 'loggedInUserEmail';
  static const _kBookings = 'bookingHistory';

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
}
