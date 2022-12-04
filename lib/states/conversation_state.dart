import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/chat/personal_chat.dart';
import '../models/chat/group_chat.dart';
import '../functions/functions.dart';
import '../main.dart';
import '../models/chat/message.dart';

class ConversationState extends GetxController {
  List<dynamic> conversations = [];

  Future<void> setupConversations() async {
    var chatDocuments = await firestore
        .collection("conversations")
        .where('participants', arrayContains: userState.userId)
        .get();
    conversations = await getConversationsFromSnapshot(chatDocuments);
    sort();
    listenConversations();
  }

  sort() {
    conversations.sort(((a, b) =>
        b.getTimeOfLatestMessage.compareTo(a.getTimeOfLatestMessage)));
    for (var convo in conversations) {
      print(convo.runtimeType);
    }
    update();
  }

  Future<List<dynamic>> getConversationsFromSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    List<dynamic> convos = [];
    for (var chatDoc in snapshot.docs) {
      if (conversations
          .any((element) => element.conversationId == chatDoc.id)) {
        convos.add(conversations
            .singleWhere((element) => element.conversationId == chatDoc.id));
      } else {
        if (chatDoc.data()['type'] == "group") {
          convos.add(await GroupChat.fromDocument(chatDoc));
        } else {
          convos.add(await PersonalChat.fromDocument(chatDoc));
        }
      }
    }
    for (var exConvos in conversations.where((element) =>
        !snapshot.docs.any((doc) => doc.id == element.conversationId))) {
      if (exConvos is GroupChat) {
        GetInstance().delete<GroupChat>(tag: exConvos.conversationId);
      } else {
        GetInstance().delete<PersonalChat>(tag: exConvos.conversationId);
      }
    }
    return convos;
  }

  dynamic findConversation(String id) {
    if (conversations.any((element) => element.conversationId == id)) {
      return conversations
          .singleWhere((element) => element.conversationId == id);
    } else {
      return null;
    }
  }

  void listenConversations() {
    firestore
        .collection("conversations")
        .where('participants', arrayContains: userState.userId)
        .snapshots()
        .listen((event) async {
      conversations = await getConversationsFromSnapshot(event);
      sort();
    });
  }
}
