import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../models/rsvp_model.dart';
import '../../services/rsvp_service.dart';
import '../../services/event_service.dart';
import '../../services/connectivity_service.dart';
import '../../widgets/rsvp_badge.dart';
import '../../widgets/sync_status_widget.dart';
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
  final RsvpService _rsvpService = RsvpService();
  final EventService _eventService = EventService();
  RsvpModel? _currentUserRsvp;
  Map<RsvpStatus, int> _rsvpCounts = {
    RsvpStatus.attending: 0,
    RsvpStatus.maybe: 0,
    RsvpStatus.declined: 0,
    RsvpStatus.pending: 0,
  };
  bool _isLoading = true;

  String? get _currentUserEmail => FirebaseAuth.instance.currentUser?.email;
  String? get _currentUserId => FirebaseAuth.instance.currentUser?.uid;
  bool get _isCreator => widget.event.creatorId == _currentUserId;
  bool get _isInvited => widget.event.invitedUserIds.contains(_currentUserEmail);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final rsvp = await _rsvpService.getUserRsvpForEvent(widget.event.id);
    final counts = await _rsvpService.getRsvpCounts(widget.event.id);

    if (mounted) {
      setState(() {
        _currentUserRsvp = rsvp;
        _rsvpCounts = {
          RsvpStatus.attending: counts['attending'] ?? 0,
          RsvpStatus.maybe: counts['maybe'] ?? 0,
          RsvpStatus.declined: counts['declined'] ?? 0,
          RsvpStatus.pending: counts['pending'] ?? 0,
        };
        _isLoading = false;
      });
    }
  }

  Future<void> _updateRsvpStatus(RsvpStatus newStatus) async {
    final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
    final isOnline = connectivityService.isOnline;

    final result = await _rsvpService.updateRsvpStatus(
      eventId: widget.event.id,
      status: newStatus,
      isOnline: isOnline,
    );

    if (!mounted) return;

    final error = result['error'];
    final message = result['message'];
    final isOffline = result['isOffline'] ?? false;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Reload data to get updated RSVP
      await _loadData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message ?? 'RSVP updated'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isOffline ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Event Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          if (_isCreator) ...[
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: _showInviteDialog,
              tooltip: 'Invite User',
            ),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.event.title,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SyncStatusWidget(
                        status: widget.event.syncStatus,
                        isSmall: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isCreator ? 'Created by you' : 'By ${widget.event.creatorName}',
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
                  RsvpCountWidget(counts: _rsvpCounts),
                  if (_isCreator) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showInviteDialog,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Invite Someone'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Divider(height: 1),

            // Invited users section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invited (${widget.event.invitedUserIds.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.event.invitedUserIds.isEmpty)
                    Text(
                      'No one invited yet',
                      style: TextStyle(color: Colors.grey[600]),
                    )
                  else
                    ...widget.event.invitedUserIds.map((email) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                            child: Text(
                              email[0].toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(email)),
                        ],
                      ),
                    )),
                ],
              ),
            ),
          ],
        ),
      ),
      // Show RSVP buttons for invited users (not creator)
      bottomNavigationBar: !_isCreator && _isInvited
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

  void _showInviteDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite User'),
        content: TextField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Enter user email',
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;

              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
              final isOnline = connectivityService.isOnline;
              Navigator.pop(context);

              final result = await _rsvpService.inviteUserByEmail(
                eventId: widget.event.id,
                email: email,
                isOnline: isOnline,
              );

              if (!mounted) return;

              final error = result['error'];
              final message = result['message'];
              final isOffline = result['isOffline'] ?? false;

              if (error == null) {
                // Reload data to show updated invited list
                await _loadData();
              }

              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(message ?? error ?? 'Invitation sent'),
                  backgroundColor: error != null ? Colors.red : (isOffline ? Colors.orange : Colors.green),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Invite'),
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
        content: const Text('Event editing coming soon!'),
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
            onPressed: () async {
              final connectivityService = Provider.of<ConnectivityService>(context, listen: false);
              final isOnline = connectivityService.isOnline;
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);

              navigator.pop(); // Close dialog

              final result = await _eventService.deleteEvent(widget.event.id, isOnline);

              if (!mounted) return;

              final error = result['error'];
              final message = result['message'];
              final isOffline = result['isOffline'] ?? false;

              if (error != null) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(error),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                navigator.pop(); // Go back to home
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(message ?? 'Event deleted'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: isOffline ? Colors.orange : Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
