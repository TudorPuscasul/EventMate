import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/connectivity/connectivity.dart';

/// Displays a banner when the device is offline.
///
/// BLoC Pattern: Uses BlocBuilder to rebuild only when ConnectivityState changes.
/// BlocBuilder<CubitType, StateType> automatically finds the Cubit from context
/// and rebuilds when state.props change (thanks to Equatable).
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        if (state.isOnline) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Material(
            color: Colors.orange.shade700,
            elevation: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(
                    Icons.cloud_off,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Offline - Changes saved locally',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.info_outline,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

