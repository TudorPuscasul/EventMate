import 'package:flutter/material.dart';
import '../models/event_model.dart';

class SyncStatusWidget extends StatelessWidget {
  final SyncStatus status;
  final bool isSmall;

  const SyncStatusWidget({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String tooltip;

    switch (status) {
      case SyncStatus.synced:
        icon = Icons.cloud_done;
        color = Colors.green;
        tooltip = 'Synced';
        break;
      case SyncStatus.pending:
        icon = Icons.cloud_upload;
        color = Colors.orange;
        tooltip = 'Syncing...';
        break;
      case SyncStatus.failed:
        icon = Icons.cloud_off;
        color = Colors.red;
        tooltip = 'Sync failed';
        break;
    }

    final widget = Icon(
      icon,
      size: isSmall ? 16 : 20,
      color: color,
    );

    if (isSmall) {
      return Tooltip(
        message: tooltip,
        child: widget,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget,
        const SizedBox(width: 4),
        Text(
          tooltip,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
