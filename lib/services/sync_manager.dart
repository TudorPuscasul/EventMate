import 'package:flutter/foundation.dart';

class SyncManager extends ChangeNotifier {
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  bool get isSyncing => _isSyncing;
  DateTime? get lastSyncTime => _lastSyncTime;

  String get lastSyncText {
    if (_lastSyncTime == null) return 'Never synced';

    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // Simulate a sync operation
  Future<void> triggerSync() async {
    if (_isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    // Simulate network delay for sync
    await Future.delayed(const Duration(seconds: 1));

    _lastSyncTime = DateTime.now();
    _isSyncing = false;
    notifyListeners();
  }

  void markSynced() {
    _lastSyncTime = DateTime.now();
    notifyListeners();
  }
}
