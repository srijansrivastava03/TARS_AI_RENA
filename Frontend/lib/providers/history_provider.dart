import 'package:flutter/foundation.dart';
import '../models/history_item.dart';
import '../services/api_service.dart';

/// Provider that manages detection history
class HistoryProvider extends ChangeNotifier {
  final ApiService _api;

  HistoryProvider(this._api);

  // ─── State ─────────────────────────────────────────────────────────
  List<HistoryItem> _items = [];
  bool _isLoading = false;
  String? _error;

  // ─── Getters ───────────────────────────────────────────────────────
  List<HistoryItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _items.isEmpty;
  int get count => _items.length;

  // ─── Load History ──────────────────────────────────────────────────
  Future<void> loadHistory(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _api.getHistory(userId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Delete ────────────────────────────────────────────────────────
  Future<bool> deleteItem(String detectionId) async {
    final success = await _api.deleteHistory(detectionId);
    if (success) {
      _items.removeWhere((item) => item.id == detectionId);
      notifyListeners();
    }
    return success;
  }

  // ─── Clear local ──────────────────────────────────────────────────
  void clear() {
    _items = [];
    _error = null;
    notifyListeners();
  }
}
