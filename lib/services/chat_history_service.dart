import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_session.dart';
import '../models/chat_message.dart';

class ChatHistoryService {
  static const _key = 'chat_sessions';

  // Get all sessions, newest first
  static Future<List<ChatSession>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    final List decoded = jsonDecode(raw);
    final list = decoded
        .map((e) => ChatSession.fromJson(e as Map<String, dynamic>))
        .toList();

    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  // Save or update a session
  static Future<void> save(ChatSession session) async {
    final list = await getAll();
    final index = list.indexWhere((s) => s.id == session.id);
    if (index == -1) {
      list.add(session);
    } else {
      list[index] = session;
    }
    await _persist(list);
  }

  // Delete a session
  static Future<void> delete(String id) async {
    final list = await getAll();
    list.removeWhere((s) => s.id == id);
    await _persist(list);
  }

  // Delete everything
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // Auto-generate a title from the first user message
  static String generateTitle(List<ChatMessage> messages) {
    final firstUser = messages.firstWhere(
      (m) => m.isUser,
      orElse: () => ChatMessage(text: 'New conversation', isUser: true),
    );
    final text = firstUser.text.trim();
    if (text.length <= 40) return text;
    return '${text.substring(0, 40)}...';
  }

  static Future<void> _persist(List<ChatSession> list) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(list.map((s) => s.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
