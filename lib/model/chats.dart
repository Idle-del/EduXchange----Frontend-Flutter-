import 'package:cloud_firestore/cloud_firestore.dart';

class Chats {
  final String id;
  final List<dynamic> participants;
  final String lastMessage;
  final DateTime? lastMessageTimestamp;
  final int? lastMessageSenderId;
  final List<dynamic> readBy;

  Chats({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    this.lastMessageSenderId,
    this.readBy = const [],
  });

  factory Chats.fromFirestore(String id, Map<String, dynamic> data) {
    return Chats(
      id: id,
      participants: data['participants'] ?? [],
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTimestamp: data['lastMessageTimestamp'] != null
          ? (data['lastMessageTimestamp'] as Timestamp).toDate()
          : null,
      lastMessageSenderId: data['lastMessageSenderId'] as int?,
      readBy: data['readBy'] ?? [],
    );
  }

  /// True if [userId] has NOT yet seen the latest message in this chat.
  /// A user's own sent message is never shown as "unread" to themselves.
  bool isUnreadFor(int userId) {
    if (lastMessageSenderId == null || lastMessageSenderId == userId) {
      return false;
    }
    return !readBy.contains(userId);
  }
}