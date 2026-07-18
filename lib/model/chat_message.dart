import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final int senderId;
  final int receiverId;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromFirestore(
    String id,
    Map<String, dynamic> data,
   ) {
    return ChatMessage(
      id: id,
      senderId: data['senderId'] as int,
      receiverId:data['receiverId'] as int,
      message: data['message'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
   }

   Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
    };
   }
}
