import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/rsvp_model.dart';

class RsvpService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  String? get currentUserName => _auth.currentUser?.displayName;
  String? get currentUserEmail => _auth.currentUser?.email;

  // Invite a user to an event by email
  Future<String?> inviteUserByEmail({
    required String eventId,
    required String email,
  }) async {
    try {
      // Check if email is valid
      if (email.isEmpty) {
        return 'Please enter an email address';
      }

      // Get event document
      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      if (!eventDoc.exists) {
        return 'Event not found';
      }

      // Add email to invitedUserIds (we'll use email as identifier for simplicity)
      final invitedUserIds = List<String>.from(eventDoc.data()?['invitedUserIds'] ?? []);

      if (invitedUserIds.contains(email)) {
        return 'User already invited';
      }

      invitedUserIds.add(email);
      await _firestore.collection('events').doc(eventId).update({
        'invitedUserIds': invitedUserIds,
      });

      // Create an RSVP record with pending status
      await _firestore.collection('rsvps').add({
        'eventId': eventId,
        'userEmail': email,
        'userId': email, // Use email as ID until they sign up
        'userName': email.split('@').first, // Use email prefix as name
        'status': RsvpStatus.pending.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return null; // Success
    } catch (e) {
      return 'Failed to invite user: $e';
    }
  }

  // Get RSVPs for an event
  Stream<List<RsvpModel>> getRsvpsForEvent(String eventId) {
    return _firestore
        .collection('rsvps')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => _rsvpFromFirestore(doc))
            .toList());
  }

  // Get current user's RSVP for an event
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

  // Update RSVP status
  Future<String?> updateRsvpStatus({
    required String eventId,
    required RsvpStatus status,
  }) async {
    if (currentUserEmail == null) {
      return 'User not logged in';
    }

    try {
      // Find existing RSVP
      final snapshot = await _firestore
          .collection('rsvps')
          .where('eventId', isEqualTo: eventId)
          .where('userEmail', isEqualTo: currentUserEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Update existing RSVP
        await snapshot.docs.first.reference.update({
          'status': status.name,
          'userId': currentUserId,
          'userName': currentUserName ?? currentUserEmail!.split('@').first,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new RSVP (shouldn't happen normally)
        await _firestore.collection('rsvps').add({
          'eventId': eventId,
          'userEmail': currentUserEmail,
          'userId': currentUserId,
          'userName': currentUserName ?? currentUserEmail!.split('@').first,
          'status': status.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return null; // Success
    } catch (e) {
      return 'Failed to update RSVP: $e';
    }
  }

  // Get RSVP counts for an event
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
