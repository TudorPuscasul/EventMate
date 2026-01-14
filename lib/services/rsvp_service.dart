import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/rsvp_model.dart';

class RsvpService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserName => _auth.currentUser?.displayName;
  String? get currentUserEmail => _auth.currentUser?.email;

  Future<Map<String, dynamic>> inviteUserByEmail({
    required String eventId,
    required String email,
    required bool isOnline,
  }) async {
    try {
      if (email.isEmpty) {
        return {'error': 'Please enter an email address', 'isOffline': false};
      }

      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        return {'error': 'Event not found', 'isOffline': false};
      }

      final invitedUserIds = List<String>.from(eventDoc.data()?['invitedUserIds'] ?? []);

      if (invitedUserIds.contains(email)) {
        return {'error': 'User already invited', 'isOffline': false};
      }

      invitedUserIds.add(email);
      await _firestore.collection('events').doc(eventId).update({
        'invitedUserIds': invitedUserIds,
      });

      await _firestore.collection('rsvps').add({
        'eventId': eventId,
        'userEmail': email,
        'userId': email,
        'userName': email.split('@').first,
        'status': RsvpStatus.pending.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'error': null,
        'message': isOnline
            ? 'Invitation sent to $email'
            : 'Invitation saved locally, will sync when online',
        'isOffline': !isOnline
      };
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' || e.message?.contains('network') == true) {
        return {
          'error': null,
          'message': 'Invitation saved locally, will sync when online',
          'isOffline': true
        };
      }
      return {'error': 'Failed to invite user: ${e.message}', 'isOffline': false};
    } catch (e) {
      return {'error': 'Failed to invite user: $e', 'isOffline': false};
    }
  }

  Stream<List<RsvpModel>> getRsvpsForEvent(String eventId) {
    return _firestore
        .collection('rsvps')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _rsvpFromFirestore(doc))
            .toList());
  }

  Future<RsvpModel?> getUserRsvpForEvent(String eventId) async {
    if (currentUserEmail == null) return null;

    try {
      final snapshot = await _firestore
          .collection('rsvps')
          .where('eventId', isEqualTo: eventId)
          .where('userEmail', isEqualTo: currentUserEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return _rsvpFromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> updateRsvpStatus({
    required String eventId,
    required RsvpStatus status,
    required bool isOnline,
  }) async {
    if (currentUserEmail == null) {
      return {'error': 'User not logged in', 'isOffline': false};
    }

    try {
      final snapshot = await _firestore
          .collection('rsvps')
          .where('eventId', isEqualTo: eventId)
          .where('userEmail', isEqualTo: currentUserEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'status': status.name,
          'userId': currentUserId,
          'userName': currentUserName ?? currentUserEmail!.split('@').first,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        await _firestore.collection('rsvps').add({
          'eventId': eventId,
          'userEmail': currentUserEmail,
          'userId': currentUserId,
          'userName': currentUserName ?? currentUserEmail!.split('@').first,
          'status': status.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return {
        'error': null,
        'message': isOnline
            ? 'RSVP updated to ${status.name}'
            : 'RSVP saved locally, will sync when online',
        'isOffline': !isOnline
      };
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' || e.message?.contains('network') == true) {
        return {
          'error': null,
          'message': 'RSVP saved locally, will sync when online',
          'isOffline': true
        };
      }
      return {'error': 'Failed to update RSVP: ${e.message}', 'isOffline': false};
    } catch (e) {
      return {'error': 'Failed to update RSVP: $e', 'isOffline': false};
    }
  }

  Future<Map<String, int>> getRsvpCounts(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('rsvps')
          .where('eventId', isEqualTo: eventId)
          .get();

      int attending = 0;
      int maybe = 0;
      int declined = 0;
      int pending = 0;

      for (var doc in snapshot.docs) {
        final status = doc.data()['status'] as String;
        switch (status) {
          case 'attending':
            attending++;
            break;
          case 'maybe':
            maybe++;
            break;
          case 'declined':
            declined++;
            break;
          case 'pending':
            pending++;
            break;
        }
      }

      return {
        'attending': attending,
        'maybe': maybe,
        'declined': declined,
        'pending': pending,
      };
    } catch (e) {
      return {'attending': 0, 'maybe': 0, 'declined': 0, 'pending': 0};
    }
  }

  RsvpModel _rsvpFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return RsvpModel(
      id: doc.id,
      eventId: data['eventId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      status: RsvpStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => RsvpStatus.pending,
      ),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
