import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_xchange/model/chat_message.dart';
import 'package:edu_xchange/model/chats.dart';

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
    final chatRef = _firestore.collection('chats').doc(chatId);

    // Update or create the chat document with the latest message and
    // timestamp. `readBy` resets to just the sender, since a fresh message
    // means only they have seen it so far.
    await chatRef.set({
      'participants': [senderId, receiverId],
      'lastMessage': message.trim(),
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
      'lastMessageSenderId': senderId,
      'readBy': [senderId],
    }, SetOptions(merge: true));

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

  /// Marks the chat's latest message as read by [userId]. Call this when
  /// the user opens a chat so the chat list can stop bolding it.
  Future<void> markChatAsRead(String chatId, int userId) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    await chatRef.set({
      'readBy': FieldValue.arrayUnion([userId]),
    }, SetOptions(merge: true));
  }

  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ChatMessage.fromFirestore(doc.id, doc.data());
          }).toList();
        });
  }

  Stream<List<Chats>> getChats(int currentUserId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Chats.fromFirestore(doc.id, doc.data());
          }).toList();
        });
  }
}