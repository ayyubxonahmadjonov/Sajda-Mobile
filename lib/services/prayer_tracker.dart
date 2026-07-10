import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Namoz tracker uchun ma'lumotlarni SharedPreferences'da saqlaydi.
///
/// Har bir kun uchun o'qilgan namozlar to'plami (bomdod, peshin, asr, shom,
/// xufton) va foydalanuvchi tanlagan "challenge" (necha kunlik maqsad)
/// saqlanadi.
class PrayerTracker {
  static const _dataKey = 'prayer_tracker_data';
  static const _goalKey = 'prayer_challenge_goal';
  static const _startKey = 'prayer_challenge_start';

  /// 5 vaqt namoz kalitlari (tartib bilan).
  static const List<String> prayerKeys = [
    'bomdod',
    'peshin',
    'asr',
    'shom',
    'xufton',
  ];

  static const Map<String, String> prayerNames = {
    'bomdod': 'Bomdod',
    'peshin': 'Peshin',
    'asr': 'Asr',
    'shom': 'Shom',
    'xufton': 'Xufton',
  };

  /// "yyyy-MM-dd" formatidagi sana kaliti.
  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static Future<Map<String, List<String>>> _readAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_dataKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = json.decode(raw) as Map<String, dynamic>;
      return decoded.map(
        (k, v) => MapEntry(k, (v as List).map((e) => e.toString()).toList()),
      );
    } catch (_) {
      return {};
    }
  }

  static Future<void> _writeAll(Map<String, List<String>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dataKey, json.encode(data));
  }

  /// Berilgan kundagi o'qilgan namozlar.
  static Future<Set<String>> getPrayed(DateTime day) async {
    final all = await _readAll();
    return (all[dateKey(day)] ?? const <String>[]).toSet();
  }

  /// Namozni belgilash / bekor qilish.
  static Future<Set<String>> toggle(DateTime day, String prayerKey) async {
    final all = await _readAll();
    final key = dateKey(day);
    final set = (all[key] ?? const <String>[]).toSet();
    if (set.contains(prayerKey)) {
      set.remove(prayerKey);
    } else {
      set.add(prayerKey);
    }
    if (set.isEmpty) {
      all.remove(key);
    } else {
      all[key] = set.toList();
    }
    await _writeAll(all);
    return set;
  }

  /// Berilgan kunда barcha 5 vaqt o'qilganmi?
  static bool _isComplete(List<String>? prayed) =>
      prayed != null && prayerKeys.every(prayed.contains);

  /// Joriy ketma-ketlik (streak) — bugundan (yoki kechadan) orqaga qarab
  /// nechta kun ketma-ket to'liq 5 vaqt o'qilgani.
  ///
  /// Agar bugun hali to'liq bo'lmasa, streak buzilmaydi — kechadan hisoblaydi.
  static Future<int> currentStreak() async {
    final all = await _readAll();
    final today = DateTime.now();
    var cursor = DateTime(today.year, today.month, today.day);

    // Bugun to'liq bo'lmasa, kechadan boshlaymiz.
    if (!_isComplete(all[dateKey(cursor)])) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    int streak = 0;
    while (_isComplete(all[dateKey(cursor)])) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Umuman to'liq o'qilgan kunlar soni.
  static Future<int> totalCompleteDays() async {
    final all = await _readAll();
    return all.values.where(_isComplete).length;
  }

  // ─── Challenge ────────────────────────────────────────────────────────────

  /// (goalDays, startDate) — challenge o'rnatilmagan bo'lsa null.
  static Future<({int goalDays, DateTime start})?> getChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final goal = prefs.getInt(_goalKey);
    final start = prefs.getString(_startKey);
    if (goal == null || start == null) return null;
    final parsed = DateTime.tryParse(start);
    if (parsed == null) return null;
    return (goalDays: goal, start: parsed);
  }

  static Future<void> startChallenge(int goalDays) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setInt(_goalKey, goalDays);
    await prefs.setString(
      _startKey,
      dateKey(DateTime(now.year, now.month, now.day)),
    );
  }

  static Future<void> cancelChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_goalKey);
    await prefs.remove(_startKey);
  }

  /// Challenge boshlangandan beri to'liq o'qilgan kunlar soni.
  static Future<int> challengeCompletedDays(DateTime start) async {
    final all = await _readAll();
    final startDay = DateTime(start.year, start.month, start.day);
    int count = 0;
    for (final entry in all.entries) {
      final d = DateTime.tryParse(entry.key);
      if (d == null) continue;
      if (d.isBefore(startDay)) continue;
      if (_isComplete(entry.value)) count++;
    }
    return count;
  }
}
