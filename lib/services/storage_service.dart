import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/history_entry.dart';

/// Servicio de persistencia del historial de evaluaciones.
/// Usa SharedPreferences para almacenar un registro ligero (sin el
/// código completo) de las últimas evaluaciones.
class StorageService {
  static const String _historyKey = 'codejudge_history';
  static const int _maxEntries = 50;

  /// Obtiene el historial completo, ordenado de más reciente a más antiguo.
  Future<List<HistoryEntry>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => HistoryEntry.fromMap(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.evaluatedAt.compareTo(a.evaluatedAt));
    } catch (_) {
      return [];
    }
  }

  /// Añade una entrada al historial.
  Future<void> addEntry(HistoryEntry entry) async {
    final history = await getHistory();
    history.insert(0, entry);
    if (history.length > _maxEntries) {
      history.removeRange(_maxEntries, history.length);
    }
    await _save(history);
  }

  /// Elimina una entrada por id.
  Future<void> deleteEntry(String id) async {
    final history = await getHistory();
    history.removeWhere((e) => e.id == id);
    await _save(history);
  }

  /// Vacía todo el historial.
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> _save(List<HistoryEntry> history) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(history.map((e) => e.toMap()).toList());
    await prefs.setString(_historyKey, raw);
  }
}
