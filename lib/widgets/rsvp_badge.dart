import 'package:flutter/material.dart';
import '../models/rsvp_model.dart';
import '../theme/app_theme.dart';

class RsvpBadge extends StatelessWidget {
  final RsvpStatus status;
  final bool isSmall;

  const RsvpBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getBackgroundColor(),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getIcon(),
            size: isSmall ? 14 : 16,
            color: _getBackgroundColor(),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(),
            style: TextStyle(
              color: _getBackgroundColor(),
              fontSize: isSmall ? 12 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case RsvpStatus.attending:
        return AppTheme.attendingColor;
      case RsvpStatus.declined:
        return AppTheme.declinedColor;
      case RsvpStatus.maybe:
        return AppTheme.maybeColor;
      case RsvpStatus.pending:
        return AppTheme.pendingColor;
    }
  }

  IconData _getIcon() {
    switch (status) {
      case RsvpStatus.attending:
        return Icons.check_circle;
      case RsvpStatus.declined:
        return Icons.cancel;
      case RsvpStatus.maybe:
        return Icons.help;
      case RsvpStatus.pending:
        return Icons.schedule;
    }
  }

  String _getStatusText() {
    switch (status) {
      case RsvpStatus.attending:
        return 'Attending';
      case RsvpStatus.declined:
        return 'Declined';
      case RsvpStatus.maybe:
        return 'Maybe';
      case RsvpStatus.pending:
        return 'Pending';
    }
  }
}

class RsvpCountWidget extends StatelessWidget {
  final Map<RsvpStatus, int> counts;

  const RsvpCountWidget({
    super.key,
    required this.counts,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildCountItem(
          Icons.check_circle,
          counts[RsvpStatus.attending] ?? 0,
          AppTheme.attendingColor,
        ),
        const SizedBox(width: 12),
        _buildCountItem(
          Icons.help,
          counts[RsvpStatus.maybe] ?? 0,
          AppTheme.maybeColor,
        ),
        const SizedBox(width: 12),
        _buildCountItem(
          Icons.cancel,
          counts[RsvpStatus.declined] ?? 0,
          AppTheme.declinedColor,
        ),
      ],
    );
  }

  Widget _buildCountItem(IconData icon, int count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
