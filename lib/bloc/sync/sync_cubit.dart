import 'package:flutter_bloc/flutter_bloc.dart';
import 'sync_state.dart';

/// Cubit for managing sync status.
///
/// Tracks whether a sync operation is in progress and when
/// the last successful sync occurred.
class SyncCubit extends Cubit<SyncState> {
  SyncCubit() : super(const SyncState.initial());

  /// Trigger a sync operation.
  Future<void> triggerSync() async {
    if (state.isSyncing) return;

    emit(state.copyWith(isSyncing: true));

    // Simulate network delay for sync
    await Future.delayed(const Duration(seconds: 1));

    emit(SyncState(
      isSyncing: false,
      lastSyncTime: DateTime.now(),
    ));
  }

  /// Mark as synced without performing actual sync.
  void markSynced() {
    emit(state.copyWith(
      lastSyncTime: DateTime.now(),
    ));
  }
}
