import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_xchange/model/chat_message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getRoomId(int userId1, int userId2) {
    if (userId1 < userId2) {
      return '${userId1}_$userId2';
    } else {
      return '${userId2}_$userId1';
    }
  }

  Future<void> sendMessage(
    String chatId,
    int senderId,
    int receiverId,
    String message,
  ) async {
    final chatMessage = ChatMessage(
      id: '',
      senderId: senderId,
      receiverId: receiverId,
      message: message.trim(),
      timestamp: DateTime.now(),
    );
    final data = chatMessage.toMap();
    data['timestamp'] = FieldValue.serverTimestamp();
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(data);
  }

  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots().map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChatMessage.fromFirestore(doc.id, doc.data());
          }).toList();
        });
  }
}
