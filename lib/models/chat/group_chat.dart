import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'chat_service.dart';
import 'message.dart';

class GroupChat extends GetxController {
  late DateTime _createdAt;
  late String _createdBy;
  late List<String> _admins;
  late String _name;
  late List<String> _participants;
  late String _conversationId;
  late List<Message> _chatMessages;
  DateTime get createdAt => this._createdAt;

  String get createdBy => this._createdBy;

  List<String> get admins => this._admins;

  String get name => this._name;

  List<String> get participants => this._participants;

  String get conversationId => this._conversationId;

  List<Message> get chatMessages => this._chatMessages;

  GroupChat(
      {required DateTime createdAt,
      required String createdBy,
      required List<String> admins,
      required String name,
      required List<String> participants,
      required String conversationId,
      required List<Message> chatMessages}) {
    _createdAt = createdAt;
    _createdBy = createdBy;
    _admins = admins;
    _name = name;
    _participants = participants;
    _conversationId = conversationId;
    _chatMessages = chatMessages;
    listenMessages();
  }
  
  DateTime get getTimeOfLatestMessage {
    return _chatMessages.isNotEmpty ? _chatMessages.last.sentAt : createdAt;
  }

  @override 
  void dispose(){
    super.dispose();
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': _createdAt,
      'createdBy': _createdBy,
      'admins': _admins,
      'name': _name,
      'participants': _participants,
      'type': "group",
    };
  }

  static Future<GroupChat> fromDocument(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    List<Message> messages = await ChatService.getMessages(snapshot.id);
    List<String> participants =
        List<String>.from(snapshot.data()!['participants']);
    for (var participant in participants) {
      if (participant != userState.userId) {
        await conversationUserState.addWithUserId(participant);
      }
    }
    return Get.put(GroupChat(
      conversationId: snapshot.id,
      createdAt: snapshot.data()!['createdAt'].toDate(),
      createdBy: snapshot.data()!['createdBy'] as String,
      admins: List<String>.from(snapshot.data()!['admins']),
      name: snapshot.data()!['name'] as String,
      participants: participants,
      chatMessages: messages,
    ));
  }


  addMessage(Message message){
    _chatMessages.add(message);
    update();
  }


  void fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    _conversationId = snapshot.id;
    _createdAt = snapshot.data()!['createdAt'];
    _createdBy = snapshot.data()!['createdBy'];
    _admins = snapshot.data()!['admins'];
    _name = snapshot.data()!['name'];
    _participants = snapshot.data()!['participants'];
  }

  void listenMessages() {
    firestore
        .collection("conversations")
        .doc(_conversationId)
        .collection("messages")
        .orderBy("sentAt", descending: false)
        .snapshots()
        .listen((event) {
      ChatService.getMessagesFromDocuments(event,
              conversationId: _conversationId)
          .then((value) {
        _chatMessages = value;
        update();
        conversationState.sort();
      });
    });
  }

  void listenGroupInformation() {
    firestore
        .collection("conversations")
        .doc(_conversationId)
        .snapshots()
        .listen((event) {
      fromSnapshot(event);
      update();
    });
  }

  String toJson() => json.encode(toMap());
}
