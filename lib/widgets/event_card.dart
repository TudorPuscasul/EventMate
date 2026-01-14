import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';
import '../models/rsvp_model.dart';
import '../services/rsvp_service.dart';
import 'rsvp_badge.dart';
import 'sync_status_widget.dart';

class EventCard extends StatefulWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  final RsvpService _rsvpService = RsvpService();
  Map<RsvpStatus, int> _rsvpCounts = {
    RsvpStatus.attending: 0,
    RsvpStatus.maybe: 0,
    RsvpStatus.declined: 0,
    RsvpStatus.pending: 0,
  };

  @override
  void initState() {
    super.initState();
    _loadRsvpCounts();
  }

  Future<void> _loadRsvpCounts() async {
    final counts = await _rsvpService.getRsvpCounts(widget.event.id);
    if (mounted) {
      setState(() {
        _rsvpCounts = {
          RsvpStatus.attending: counts['attending'] ?? 0,
          RsvpStatus.maybe: counts['maybe'] ?? 0,
          RsvpStatus.declined: counts['declined'] ?? 0,
          RsvpStatus.pending: counts['pending'] ?? 0,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isCreator = widget.event.creatorId == currentUserId;

    return Card(
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.event,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.event.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3436),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isCreator ? 'Created by you' : 'By ${widget.event.creatorName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SyncStatusWidget(
                        status: widget.event.syncStatus,
                        isSmall: true,
                      ),
                      if (widget.event.isPast) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Past',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.event.formattedDate} at ${widget.event.formattedTime}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.event.location,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              RsvpCountWidget(counts: _rsvpCounts),
            ],
          ),
        ),
      ),
    );
  }
}
