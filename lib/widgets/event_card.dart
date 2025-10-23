import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/rsvp_model.dart';
import '../utils/mock_data.dart';
import 'rsvp_badge.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final rsvpCounts = MockData.getRsvpCounts(event.id);
    final currentUserRsvp = MockData.getUserRsvpForEvent(
      event.id,
      MockData.currentUser.id,
    );
    final isCreator = event.creatorId == MockData.currentUser.id;

    return Card(
      child: InkWell(
        onTap: onTap,
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
                          event.title,
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
                          isCreator ? 'Created by you' : 'By ${event.creatorName}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (event.isPast)
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
                    '${event.formattedDate} at ${event.formattedTime}',
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
                      event.location,
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
              
              Row(
                children: [
                  Expanded(
                    child: RsvpCountWidget(counts: rsvpCounts),
                  ),
                  if (currentUserRsvp != null && !isCreator)
                    RsvpBadge(
                      status: currentUserRsvp.status,
                      isSmall: true,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
