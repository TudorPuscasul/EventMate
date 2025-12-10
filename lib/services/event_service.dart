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
  Future<Map<String, dynamic>> createEvent({
    required String title,
    required String description,
    required DateTime dateTime,
    required String location,
    required bool isOnline,
  }) async {
    try {
      if (currentUserId == null) {
        return {'error': 'User not logged in', 'isOffline': false};
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

      await docRef.update({'id': docRef.id});

      return {
        'error': null,
        'message': isOnline
            ? 'Event created successfully'
            : 'Event saved locally, will sync when online',
        'isOffline': !isOnline
      };
    } on FirebaseException catch (e) {
      // Check if it's a network error
      if (e.code == 'unavailable' || e.message?.contains('network') == true) {
        return {
          'error': null,
          'message': 'Event saved locally, will sync when online',
          'isOffline': true
        };
      }
      return {'error': 'Failed to create event: ${e.message}', 'isOffline': false};
    } catch (e) {
      return {'error': 'Failed to create event: $e', 'isOffline': false};
    }
  }

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
          events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          return events;
        });
  }

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
          events.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          return events;
        });
  }

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

  Future<Map<String, dynamic>> updateEvent(EventModel event, bool isOnline) async {
    try {
      await _firestore.collection('events').doc(event.id).update({
        'title': event.title,
        'description': event.description,
        'dateTime': Timestamp.fromDate(event.dateTime),
        'location': event.location,
        'invitedUserIds': event.invitedUserIds,
      });
      return {
        'error': null,
        'message': isOnline
            ? 'Event updated successfully'
            : 'Update saved locally, will sync when online',
        'isOffline': !isOnline
      };
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' || e.message?.contains('network') == true) {
        return {
          'error': null,
          'message': 'Update saved locally, will sync when online',
          'isOffline': true
        };
      }
      return {'error': 'Failed to update event: ${e.message}', 'isOffline': false};
    } catch (e) {
      return {'error': 'Failed to update event: $e', 'isOffline': false};
    }
  }

  Future<Map<String, dynamic>> deleteEvent(String eventId, bool isOnline) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      return {
        'error': null,
        'message': isOnline
            ? 'Event deleted successfully'
            : 'Delete queued, will sync when online',
        'isOffline': !isOnline
      };
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' || e.message?.contains('network') == true) {
        return {
          'error': null,
          'message': 'Delete queued, will sync when online',
          'isOffline': true
        };
      }
      return {'error': 'Failed to delete event: ${e.message}', 'isOffline': false};
    } catch (e) {
      return {'error': 'Failed to delete event: $e', 'isOffline': false};
    }
  }

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
