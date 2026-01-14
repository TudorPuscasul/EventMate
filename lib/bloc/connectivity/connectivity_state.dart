import 'package:equatable/equatable.dart';

/// State representing network connectivity status.
///
/// Uses Equatable for value-based comparison, which allows BLoC
/// to efficiently determine when to rebuild widgets.
class ConnectivityState extends Equatable {
  final bool isOnline;

  const ConnectivityState({required this.isOnline});

  /// Initial state assumes online until we check
  factory ConnectivityState.initial() => const ConnectivityState(isOnline: true);

  @override
  List<Object?> get props => [isOnline];
}
