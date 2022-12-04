import 'package:get/get.dart';
import 'package:whatsapp_clone/models/chat/chat_service.dart';

import 'message.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart';

class PersonalChat extends GetxController {
  late List<String> _participants = [];
  late String _conversationId;
  late List<Message> _chatMessages;

  String get chatWithUserId =>
      _participants.singleWhere((element) => element != userState.userId);

  String get conversationId => this._conversationId;

  List<Message> get chatMessages => this._chatMessages;

  DateTime get getTimeOfLatestMessage {
    return _chatMessages.last.sentAt;
  }

  PersonalChat(
      {required List<String> participants,
      required String conversationId,
      required List<Message> chatMessages}) {
    _participants = participants;
    _conversationId = conversationId;
    _chatMessages = chatMessages;
    listenMessages();
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': _participants,
      'type': "personal",
    };
  }

  addMessage(Message message) {
    _chatMessages.add(message);
    update();
  }

  static Future<PersonalChat> fromDocument(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    List<Message> messages = await ChatService.getMessages(snapshot.id);
    List<String> participants =
        List<String>.from(snapshot.data()!['participants']);
    String chatWithUserId =
        participants.singleWhere((element) => element != userState.userId);
    await conversationUserState.addWithUserId(chatWithUserId);
    return Get.put(PersonalChat(
        participants: participants,
        conversationId: snapshot.id,
        chatMessages: messages));
  }

  @override 
  void dispose(){
    super.dispose();
  }

  void listenMessages() {
    firestore
        .collection("conversations")
        .doc(conversationId)
        .collection("messages")
        .orderBy("sentAt", descending: false)
        .snapshots()
        .listen((event) {
      ChatService.getMessagesFromDocuments(event,
              conversationId: _conversationId)
          .then((value) {
        _chatMessages = value;
        conversationState.sort();
      });
    });
  }

  String toJson() => json.encode(toMap());
}
