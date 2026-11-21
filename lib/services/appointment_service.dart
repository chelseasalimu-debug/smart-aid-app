import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appointment.dart';

class AppointmentService {
  static const _key = 'appointments';

  // Get all appointments (sorted by date, soonest first)
  static Future<List<Appointment>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    final List decoded = jsonDecode(raw);
    final list = decoded
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();

    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
  }

  // Add a new appointment
  static Future<void> add(Appointment appointment) async {
    final list = await getAll();
    list.add(appointment);
    await _save(list);
  }

  // Delete an appointment
  static Future<void> delete(String id) async {
    final list = await getAll();
    list.removeWhere((a) => a.id == id);
    await _save(list);
  }

  // Mark as completed
  static Future<void> toggleCompleted(String id) async {
    final list = await getAll();
    final index = list.indexWhere((a) => a.id == id);
    if (index != -1) {
      final a = list[index];
      list[index] = Appointment(
        id: a.id,
        serviceType: a.serviceType,
        dateTime: a.dateTime,
        reason: a.reason,
        location: a.location,
        isCompleted: !a.isCompleted,
      );
      await _save(list);
    }
  }

  static Future<void> _save(List<Appointment> list) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(list.map((a) => a.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
