import 'event_model.dart';

enum RsvpStatus {
  attending,
  declined,
  maybe,
  pending,
}

class RsvpModel {
  final String id;
  final String eventId;
  final String userId;
  final String userName;
  final String userEmail;
  final RsvpStatus status;
  final DateTime updatedAt;
  final SyncStatus syncStatus;

  RsvpModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.status,
    required this.updatedAt,
    this.syncStatus = SyncStatus.synced,
  });

  String get statusText {
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

  // For later Firebase integration
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'status': status.name,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RsvpModel.fromMap(Map<String, dynamic> map) {
    return RsvpModel(
      id: map['id'] ?? '',
      eventId: map['eventId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      status: RsvpStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RsvpStatus.pending,
      ),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  RsvpModel copyWith({
    String? id,
    String? eventId,
    String? userId,
    String? userName,
    String? userEmail,
    RsvpStatus? status,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
  }) {
    return RsvpModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
