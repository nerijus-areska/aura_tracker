import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_models.dart';

class StorageService {
  static const String _morningKey = 'morning_checkins';
  static const String _eveningKey = 'evening_checkins';
  static const String _episodesKey = 'episodes';
  static const String _secondDayKey = 'second_day_logs';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Morning Check-ins ──
  List<MorningCheckin> getMorningCheckins() {
    final data = _prefs.getString(_morningKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => MorningCheckin.fromJson(e)).toList();
  }

  Future<void> saveMorningCheckin(MorningCheckin checkin) async {
    final checkins = getMorningCheckins();
    // Remove existing for same date
    checkins.removeWhere((c) => _sameDay(c.date, checkin.date));
    checkins.add(checkin);
    await _prefs.setString(
        _morningKey, jsonEncode(checkins.map((e) => e.toJson()).toList()));
  }

  MorningCheckin? getMorningCheckinForDate(DateTime date) {
    final checkins = getMorningCheckins();
    try {
      return checkins.firstWhere((c) => _sameDay(c.date, date));
    } catch (_) {
      return null;
    }
  }

  // ── Evening Check-ins ──
  List<EveningCheckin> getEveningCheckins() {
    final data = _prefs.getString(_eveningKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => EveningCheckin.fromJson(e)).toList();
  }

  Future<void> saveEveningCheckin(EveningCheckin checkin) async {
    final checkins = getEveningCheckins();
    checkins.removeWhere((c) => _sameDay(c.date, checkin.date));
    checkins.add(checkin);
    await _prefs.setString(
        _eveningKey, jsonEncode(checkins.map((e) => e.toJson()).toList()));
  }

  EveningCheckin? getEveningCheckinForDate(DateTime date) {
    final checkins = getEveningCheckins();
    try {
      return checkins.firstWhere((c) => _sameDay(c.date, date));
    } catch (_) {
      return null;
    }
  }

  // ── Episodes ──
  List<Episode> getEpisodes() {
    final data = _prefs.getString(_episodesKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    final episodes = <Episode>[];
    for (final e in list) {
      try {
        episodes.add(Episode.fromJson(e));
      } catch (_) {
        // Skip malformed records instead of losing all data
      }
    }
    return episodes;
  }

  Future<void> saveEpisode(Episode episode) async {
    final episodes = getEpisodes();
    final index = episodes.indexWhere((e) => e.id == episode.id);
    if (index >= 0) {
      episodes[index] = episode;
    } else {
      episodes.add(episode);
    }
    await _prefs.setString(
        _episodesKey, jsonEncode(episodes.map((e) => e.toJson()).toList()));
  }

  Future<void> deleteEpisode(String id) async {
    final episodes = getEpisodes();
    episodes.removeWhere((e) => e.id == id);
    await _prefs.setString(
        _episodesKey, jsonEncode(episodes.map((e) => e.toJson()).toList()));
  }

  List<Episode> getEpisodesForMonth(int year, int month) {
    return getEpisodes()
        .where((e) => e.date.year == year && e.date.month == month)
        .toList();
  }

  List<Episode> getEpisodesForQuarter(int year, int quarter) {
    final startMonth = (quarter - 1) * 3 + 1;
    return getEpisodes()
        .where((e) =>
            e.date.year == year &&
            e.date.month >= startMonth &&
            e.date.month < startMonth + 3)
        .toList();
  }


  // ── Second Day Logs ──
  List<SecondDayLog> getSecondDayLogs() {
    final data = _prefs.getString(_secondDayKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    final logs = <SecondDayLog>[];
    for (final e in list) {
      try {
        logs.add(SecondDayLog.fromJson(e));
      } catch (_) {}
    }
    return logs;
  }

  Future<void> saveSecondDayLog(SecondDayLog log) async {
    final logs = getSecondDayLogs();
    // Remove existing for same date
    logs.removeWhere((l) => _sameDay(l.date, log.date));
    logs.add(log);
    await _prefs.setString(
        _secondDayKey, jsonEncode(logs.map((e) => e.toJson()).toList()));
  }

  SecondDayLog? getSecondDayLogForDate(DateTime date) {
    final logs = getSecondDayLogs();
    try {
      return logs.firstWhere((l) => _sameDay(l.date, date));
    } catch (_) {
      return null;
    }
  }

  // ── Notification Times ──
  static const _notifMorningHour = 'notif_morning_hour';
  static const _notifMorningMin  = 'notif_morning_min';
  static const _notifEveningHour = 'notif_evening_hour';
  static const _notifEveningMin  = 'notif_evening_min';

  Map<String, int> getNotificationTimes() => {
    'morningHour': _prefs.getInt(_notifMorningHour) ?? 6,
    'morningMin':  _prefs.getInt(_notifMorningMin)  ?? 50,
    'eveningHour': _prefs.getInt(_notifEveningHour) ?? 21,
    'eveningMin':  _prefs.getInt(_notifEveningMin)  ?? 45,
  };

  Future<void> saveNotificationTimes({
    required int morningHour,
    required int morningMinute,
    required int eveningHour,
    required int eveningMinute,
  }) async {
    await _prefs.setInt(_notifMorningHour, morningHour);
    await _prefs.setInt(_notifMorningMin,  morningMinute);
    await _prefs.setInt(_notifEveningHour, eveningHour);
    await _prefs.setInt(_notifEveningMin,  eveningMinute);
  }

  // ── Helpers ──
  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ── Export ──
  Future<Map<String, dynamic>> exportAllData() async {
    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'version': 1,
      'morningCheckins': getMorningCheckins().map((e) => e.toJson()).toList(),
      'eveningCheckins': getEveningCheckins().map((e) => e.toJson()).toList(),
      'episodes': getEpisodes().map((e) => e.toJson()).toList(),
      'secondDayLogs': getSecondDayLogs().map((e) => e.toJson()).toList(),
    };
  }

  // ── Stats ──
  Map<String, dynamic> getMonthlyStats(int year, int month) {
    final episodes = getEpisodesForMonth(year, month);
    final mornings = getMorningCheckins()
        .where((c) => c.date.year == year && c.date.month == month)
        .toList();
    final evenings = getEveningCheckins()
        .where((c) => c.date.year == year && c.date.month == month)
        .toList();

    return _computeStats(episodes, mornings, evenings);
  }

  Map<String, dynamic> getQuarterlyStats(int year, int quarter) {
    final startMonth = (quarter - 1) * 3 + 1;
    final episodes = getEpisodesForQuarter(year, quarter);
    final mornings = getMorningCheckins()
        .where((c) =>
            c.date.year == year &&
            c.date.month >= startMonth &&
            c.date.month < startMonth + 3)
        .toList();
    final evenings = getEveningCheckins()
        .where((c) =>
            c.date.year == year &&
            c.date.month >= startMonth &&
            c.date.month < startMonth + 3)
        .toList();

    return _computeStats(episodes, mornings, evenings);
  }

  Map<String, dynamic> _computeStats(List<Episode> episodes,
      List<MorningCheckin> mornings, List<EveningCheckin> evenings) {
    final episodeCount = episodes.length;
    final avgPain = episodes.isEmpty
        ? 0.0
        : episodes.map((e) => e.painSeverity).reduce((a, b) => a + b) /
            episodeCount;
    final avgStress = evenings.isEmpty
        ? 0.0
        : evenings.map((e) => e.stress).reduce((a, b) => a + b) /
            evenings.length;
    final avgHydration = evenings.isEmpty
        ? 0.0
        : evenings.map((e) => e.hydration).reduce((a, b) => a + b) /
            evenings.length;
    final avgSleepQuality = mornings.isEmpty
        ? 0.0
        : mornings.map((e) => e.sleepQuality).reduce((a, b) => a + b) /
            mornings.length;
    final avgSleepDuration = mornings.isEmpty
        ? 0.0
        : mornings.map((e) => e.sleepDuration).reduce((a, b) => a + b) /
            mornings.length;

    // Aura type frequency
    final auraFrequency = <String, int>{};
    for (final ep in episodes) {
      for (final t in ep.visualAuraTypes) {
        auraFrequency[t] = (auraFrequency[t] ?? 0) + 1;
      }
    }

    // Pain location frequency
    final locationFrequency = <String, int>{};
    for (final ep in episodes) {
      locationFrequency[ep.painLocation] =
          (locationFrequency[ep.painLocation] ?? 0) + 1;
    }

    // Common lingering symptoms
    final symptomFrequency = <String, int>{};
    for (final ep in episodes) {
      if (ep.lingeringSymptoms != null) {
        for (final s in ep.lingeringSymptoms!) {
          symptomFrequency[s] = (symptomFrequency[s] ?? 0) + 1;
        }
      }
    }

    return {
      'episodeCount': episodeCount,
      'avgPain': avgPain,
      'avgStress': avgStress,
      'avgHydration': avgHydration,
      'avgSleepQuality': avgSleepQuality,
      'avgSleepDuration': avgSleepDuration,
      'auraFrequency': auraFrequency,
      'locationFrequency': locationFrequency,
      'symptomFrequency': symptomFrequency,
      'checkinDays': mornings.length,
    };
  }
}
