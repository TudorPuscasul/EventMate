import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserName => _auth.currentUser?.displayName;

  // Create a new event
  Future<String?> createEvent({
    required String title,
    required String description,
    required DateTime dateTime,
    required String location,
  }) async {
    try {
      if (currentUserId == null) {
        return 'User not logged in';
      }

      final docRef = await _firestore.collection('events').add({
        'title': title,
        'description': description,
        'dateTime': Timestamp.fromDate(dateTime),
        'location': location,
        'creatorId': currentUserId,
        'creatorName': currentUserName ?? 'Unknown',
        'invitedUserIds': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update the document with its own ID
      await docRef.update({'id': docRef.id});

      return null; // Success
    } catch (e) {
      return 'Failed to create event: $e';
    }
  }

  // Get events created by current user
  Stream<List<EventModel>> getMyEvents() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('events')
        .where('creatorId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs
              .map((doc) => _eventFromFirestore(doc))
              .toList();
          // Sort locally by dateTime
          events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          return events;
        });
  }

  // Get events where current user is invited (by email)
  Stream<List<EventModel>> getInvitedEvents() {
    final userEmail = _auth.currentUser?.email;
    if (userEmail == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('events')
        .where('invitedUserIds', arrayContains: userEmail)
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs
              .map((doc) => _eventFromFirestore(doc))
              .toList();
          // Sort locally by dateTime
          events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          return events;
        });
  }

  // Get a single event by ID
  Future<EventModel?> getEvent(String eventId) async {
    try {
      final doc = await _firestore.collection('events').doc(eventId).get();
      if (doc.exists) {
        return _eventFromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update an event
  Future<String?> updateEvent(EventModel event) async {
    try {
      await _firestore.collection('events').doc(event.id).update({
        'title': event.title,
        'description': event.description,
        'dateTime': Timestamp.fromDate(event.dateTime),
        'location': event.location,
        'invitedUserIds': event.invitedUserIds,
      });
      return null; // Success
    } catch (e) {
      return 'Failed to update event: $e';
    }
  }

  // Delete an event
  Future<String?> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      return null; // Success
    } catch (e) {
      return 'Failed to delete event: $e';
    }
  }

  // Helper to convert Firestore document to EventModel
  EventModel _eventFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      location: data['location'] ?? '',
      creatorId: data['creatorId'] ?? '',
      creatorName: data['creatorName'] ?? '',
      invitedUserIds: List<String>.from(data['invitedUserIds'] ?? []),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
