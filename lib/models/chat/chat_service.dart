import 'package:cloud_firestore/cloud_firestore.dart';

import '../../main.dart';
import 'message.dart';

class ChatService {
  static Future<List<Message>> getMessages(String conversationId) async {
    var chatDocuments = await firestore
        .collection("conversations")
        .doc(conversationId)
        .collection("messages")
        .get();
    return getMessagesFromDocuments(chatDocuments,
        conversationId: conversationId);
  }

  static Future<List<Message>> getMessagesFromDocuments(
      QuerySnapshot<Map<String, dynamic>> snapshot,
      {required String conversationId}) async {
    //get all messages of a chat
    List<Message> messages = [];
    for (var messageDoc in snapshot.docs) {
      messages.add(Message.fromDocument(messageDoc));
    }
    return messages;
  }
}
