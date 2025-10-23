import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../models/rsvp_model.dart';
import '../../utils/mock_data.dart';
import '../../widgets/rsvp_badge.dart';
import '../../theme/app_theme.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late List<RsvpModel> _rsvps;
  late RsvpModel? _currentUserRsvp;
  final bool _isCreator = MockData.currentUser.id == MockData.events.first.creatorId;

  @override
  void initState() {
    super.initState();
    _loadRsvps();
  }

  void _loadRsvps() {
    _rsvps = MockData.getRsvpsForEvent(widget.event.id);
    _currentUserRsvp = MockData.getUserRsvpForEvent(
      widget.event.id,
      MockData.currentUser.id,
    );
  }

  void _updateRsvpStatus(RsvpStatus newStatus) {
    setState(() {
      if (_currentUserRsvp != null) {
        _currentUserRsvp = _currentUserRsvp!.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('RSVP updated to ${newStatus.name}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCreator = widget.event.creatorId == MockData.currentUser.id;
    final rsvpCounts = MockData.getRsvpCounts(widget.event.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          if (isCreator)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditDialog();
                } else if (value == 'delete') {
                  _showDeleteDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit Event'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Event', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.event.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCreator ? 'Created by you' : 'By ${widget.event.creatorName}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            _buildInfoSection(
              icon: Icons.calendar_today,
              title: 'Date & Time',
              content: '${widget.event.formattedDate} at ${widget.event.formattedTime}',
            ),

            const Divider(height: 1),

            _buildInfoSection(
              icon: Icons.location_on,
              title: 'Location',
              content: widget.event.location,
            ),

            const Divider(height: 1),

            _buildInfoSection(
              icon: Icons.description,
              title: 'Description',
              content: widget.event.description,
            ),

            const Divider(height: 1, thickness: 8),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RSVP Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  RsvpCountWidget(counts: rsvpCounts),
                ],
              ),
            ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendees (${_rsvps.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._rsvps.map((rsvp) => _buildAttendeeItem(rsvp)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: !isCreator && _currentUserRsvp != null
          ? _buildRsvpButtons()
          : null,
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeeItem(RsvpModel rsvp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Text(
              rsvp.userName[0].toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rsvp.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  rsvp.userEmail,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          RsvpBadge(status: rsvp.status, isSmall: true),
        ],
      ),
    );
  }

  Widget _buildRsvpButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your Response: ${_currentUserRsvp?.statusText ?? "Pending"}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildRsvpButton(
                    'Attending',
                    Icons.check_circle,
                    AppTheme.attendingColor,
                    RsvpStatus.attending,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRsvpButton(
                    'Maybe',
                    Icons.help,
                    AppTheme.maybeColor,
                    RsvpStatus.maybe,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildRsvpButton(
                    'Decline',
                    Icons.cancel,
                    AppTheme.declinedColor,
                    RsvpStatus.declined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRsvpButton(
    String label,
    IconData icon,
    Color color,
    RsvpStatus status,
  ) {
    final isSelected = _currentUserRsvp?.status == status;
    
    return ElevatedButton(
      onPressed: () => _updateRsvpStatus(status),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 12),
        elevation: isSelected ? 2 : 0,
      ),
      child: Column(
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Event'),
        content: const Text('Event editing will be implemented in Milestone 2 with Firebase integration.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Event deleted successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
