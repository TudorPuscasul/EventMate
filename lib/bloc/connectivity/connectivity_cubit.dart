import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'connectivity_state.dart';

/// Cubit for managing network connectivity state.
///
/// A Cubit is a simplified BLoC that exposes methods to emit new states
/// directly, without requiring separate Event classes. It's ideal for
/// simple state management like boolean flags.
///
/// Key BLoC concepts demonstrated:
/// - State is immutable (ConnectivityState)
/// - State changes via emit() only
/// - Cubit automatically notifies listeners on state change
class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Connectivity _connectivity;
  StreamSubscription<ConnectivityResult>? _subscription;

  ConnectivityCubit({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity(),
        super(ConnectivityState.initial()) {
    _init();
  }

  void _init() {
    // Check initial connectivity
    _checkConnectivity();

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _onConnectivityChanged(result);
    } catch (e) {
      // Assume online on error
      emit(const ConnectivityState(isOnline: true));
    }
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    final isOnline = result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;

    // Only emit if state actually changed (Equatable handles comparison)
    if (state.isOnline != isOnline) {
      emit(ConnectivityState(isOnline: isOnline));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
