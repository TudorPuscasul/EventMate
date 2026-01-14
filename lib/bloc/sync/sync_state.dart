import 'package:equatable/equatable.dart';

/// State representing sync status.
class SyncState extends Equatable {
  final bool isSyncing;
  final DateTime? lastSyncTime;

  const SyncState({
    this.isSyncing = false,
    this.lastSyncTime,
  });

  /// Initial state - never synced.
  const SyncState.initial() : this();

  /// Formatted text showing last sync time.
  String get lastSyncText {
    if (lastSyncTime == null) return 'Never synced';

    final now = DateTime.now();
    final difference = now.difference(lastSyncTime!);

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

  SyncState copyWith({
    bool? isSyncing,
    DateTime? lastSyncTime,
  }) {
    return SyncState(
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  @override
  List<Object?> get props => [isSyncing, lastSyncTime];
}
