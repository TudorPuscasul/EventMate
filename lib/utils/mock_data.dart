import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/rsvp_model.dart';

class MockData {
  static final UserModel currentUser = UserModel(
    id: 'user1',
    name: 'test',
    email: 't@t.com',
  );

  // Mock users
  static final List<UserModel> users = [
    currentUser,
    UserModel(
      id: 'user2',
      name: 'dog',
      email: 'dog@example.com',
    ),
    UserModel(
      id: 'user3',
      name: 'Google ceo',
      email: 'satan@example.com',
    ),
    UserModel(
      id: 'user4',
      name: 'Mutu',
      email: 'Mutu@example.com',
    ),
    UserModel(
      id: 'user5',
      name: 'Duica Vlad',
      email: 'duica.vlad@example.com',
    ),
  ];

  // Mock events
  static final List<EventModel> events = [
    EventModel(
      id: 'event1',
      title: 'Team Building BBQ',
      description: 'Join us for a fun afternoon of grilling and games! Bring your appetite and competitive spirit.',
      dateTime: DateTime.now().add(const Duration(days: 3)),
      location: 'buzau, parc2',
      creatorId: 'user1',
      creatorName: 'test',
      invitedUserIds: ['user2', 'user3', 'user4', 'user5'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    EventModel(
      id: 'event2',
      title: 'Birthday Party',
      description: 'Celebrating Mike\'s 30th birthday! Dinner, drinks, and dancing. Casual dress code.',
      dateTime: DateTime.now().add(const Duration(days: 7)),
      location: 'The Rose Garden',
      creatorId: 'user3',
      creatorName: 'Google ceo',
      invitedUserIds: ['user1', 'user2', 'user4'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    EventModel(
      id: 'event3',
      title: 'Project Kickoff Meeting',
      description: 'Initial meeting to discuss project goals, timeline, and team responsibilities.',
      dateTime: DateTime.now().add(const Duration(hours: 5)),
      location: 'Concert hall',
      creatorId: 'user1',
      creatorName: 'test',
      invitedUserIds: ['user2', 'user3', 'user5'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    EventModel(
      id: 'event4',
      title: 'Weekend Hiking Trip',
      description: 'Explore the beautiful mountain trails! We\'ll start early morning and return by evening. Bring water and snacks.',
      dateTime: DateTime.now().add(const Duration(days: 10)),
      location: 'Mountain',
      creatorId: 'user2',
      creatorName: 'god',
      invitedUserIds: ['user1', 'user4', 'user5'],
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    EventModel(
      id: 'event5',
      title: 'Movie Night',
      description: 'Watching the latest blockbuster! Popcorn and drinks provided.',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      location: 'bucuresti, Downtown',
      creatorId: 'user4',
      creatorName: 'Mutu',
      invitedUserIds: ['user1', 'user2', 'user3'],
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    EventModel(
      id: 'event6',
      title: 'Study Group Session',
      description: 'Final exam preparation for Advanced Mathematics. Bring your notes and questions!',
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      location: 'City Library, Study Room 3',
      creatorId: 'user5',
      creatorName: 'Duica Vlad',
      invitedUserIds: ['user1', 'user2'],
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  // Mock RSVPs
  static final List<RsvpModel> rsvps = [
    // Event 1 RSVPs
    RsvpModel(
      id: 'rsvp1',
      eventId: 'event1',
      userId: 'user2',
      userName: 'dog',
      userEmail: 'dog@example.com',
      status: RsvpStatus.attending,
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    RsvpModel(
      id: 'rsvp2',
      eventId: 'event1',
      userId: 'user3',
      userName: 'Google ceo',
      userEmail: 'satan@example.com',
      status: RsvpStatus.attending,
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    RsvpModel(
      id: 'rsvp3',
      eventId: 'event1',
      userId: 'user4',
      userName: 'Vlad Duica',
      userEmail: 'vlad.duica@example.com',
      status: RsvpStatus.maybe,
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    RsvpModel(
      id: 'rsvp4',
      eventId: 'event1',
      userId: 'user5',
      userName: 'aoleu',
      userEmail: 'david.brown@example.com',
      status: RsvpStatus.pending,
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    
    // Event 2 RSVPs
    RsvpModel(
      id: 'rsvp5',
      eventId: 'event2',
      userId: 'user1',
      userName: 'test',
      userEmail: 't@t.com',
      status: RsvpStatus.attending,
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    RsvpModel(
      id: 'rsvp6',
      eventId: 'event2',
      userId: 'user2',
      userName: 'Jane Smith',
      userEmail: 'jane.smith@example.com',
      status: RsvpStatus.attending,
      updatedAt: DateTime.now().subtract(const Duration(hours: 18)),
    ),
    RsvpModel(
      id: 'rsvp7',
      eventId: 'event2',
      userId: 'user4',
      userName: 'Sarah Williams',
      userEmail: 'sarah.williams@example.com',
      status: RsvpStatus.declined,
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    
    // Event 3 RSVPs
    RsvpModel(
      id: 'rsvp8',
      eventId: 'event3',
      userId: 'user2',
      userName: 'Jane Smith',
      userEmail: 'jane.smith@example.com',
      status: RsvpStatus.attending,
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    RsvpModel(
      id: 'rsvp9',
      eventId: 'event3',
      userId: 'user3',
      userName: 'Mike Johnson',
      userEmail: 'mike.johnson@example.com',
      status: RsvpStatus.pending,
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    RsvpModel(
      id: 'rsvp10',
      eventId: 'event3',
      userId: 'user5',
      userName: 'David Brown',
      userEmail: 'david.brown@example.com',
      status: RsvpStatus.attending,
      updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    
    // Event 4 RSVPs
    RsvpModel(
      id: 'rsvp11',
      eventId: 'event4',
      userId: 'user1',
      userName: 'test',
      userEmail: 't@t.com',
      status: RsvpStatus.maybe,
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    RsvpModel(
      id: 'rsvp12',
      eventId: 'event4',
      userId: 'user4',
      userName: 'Sarah Williams',
      userEmail: 'sarah.williams@example.com',
      status: RsvpStatus.attending,
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    RsvpModel(
      id: 'rsvp13',
      eventId: 'event4',
      userId: 'user5',
      userName: 'David Brown',
      userEmail: 'david.brown@example.com',
      status: RsvpStatus.pending,
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    
    // Event 5 RSVPs
    RsvpModel(
      id: 'rsvp14',
      eventId: 'event5',
      userId: 'user1',
      userName: 'test',
      userEmail: 't@t.com',
      status: RsvpStatus.attending,
      updatedAt: DateTime.now().subtract(const Duration(hours: 10)),
    ),
    RsvpModel(
      id: 'rsvp15',
      eventId: 'event5',
      userId: 'user2',
      userName: 'Jane Smith',
      userEmail: 'jane.smith@example.com',
      status: RsvpStatus.attending,
      updatedAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    RsvpModel(
      id: 'rsvp16',
      eventId: 'event5',
      userId: 'user3',
      userName: 'Mike Johnson',
      userEmail: 'mike.johnson@example.com',
      status: RsvpStatus.declined,
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    
    // Event 6 RSVPs (past event)
    RsvpModel(
      id: 'rsvp17',
      eventId: 'event6',
      userId: 'user1',
      userName: 'test',
      userEmail: 't@t.com',
      status: RsvpStatus.attending,
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    RsvpModel(
      id: 'rsvp18',
      eventId: 'event6',
      userId: 'user2',
      userName: 'Jane Smith',
      userEmail: 'jane.smith@example.com',
      status: RsvpStatus.attending,
      updatedAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];

  // Helper methods to get RSVPs for specific events
  static List<RsvpModel> getRsvpsForEvent(String eventId) {
    return rsvps.where((rsvp) => rsvp.eventId == eventId).toList();
  }

  // Get RSVP counts for an event
  static Map<RsvpStatus, int> getRsvpCounts(String eventId) {
    final eventRsvps = getRsvpsForEvent(eventId);
    return {
      RsvpStatus.attending: eventRsvps.where((r) => r.status == RsvpStatus.attending).length,
      RsvpStatus.declined: eventRsvps.where((r) => r.status == RsvpStatus.declined).length,
      RsvpStatus.maybe: eventRsvps.where((r) => r.status == RsvpStatus.maybe).length,
      RsvpStatus.pending: eventRsvps.where((r) => r.status == RsvpStatus.pending).length,
    };
  }

  // Get current user's RSVP for an event
  static RsvpModel? getUserRsvpForEvent(String eventId, String userId) {
    try {
      return rsvps.firstWhere(
        (rsvp) => rsvp.eventId == eventId && rsvp.userId == userId,
      );
    } catch (e) {
      return null;
    }
  }

  // Get events created by user
  static List<EventModel> getEventsCreatedByUser(String userId) {
    return events.where((event) => event.creatorId == userId).toList();
  }

  // Get events user is invited to
  static List<EventModel> getEventsUserInvitedTo(String userId) {
    return events.where((event) => event.invitedUserIds.contains(userId)).toList();
  }
}
