import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '/models/user/conversation_user.dart';

import '../models/user/phone.dart';
import '../main.dart';

class ConversationUserState extends GetxController {
  List<ConversationUser> _items = [];

  List<ConversationUser> get items => _items;
  Future<void>addWithUserId(String userId) async {
    if (!_items.any((element) => element.userId == userId)) {
      ConversationUser? user = await ConversationUser.withId(userId);
      if (user != null) addItem(user);
    }
  }

  void addItem(ConversationUser item) {
    _items.add(Get.put(item, tag: item.userId));
    update();
  }

  void removeItem(ConversationUser item) {
    _items.remove(item);
    GetInstance().delete<ConversationUser>(tag: item.userId);
    update();
  }

  void updateItem(ConversationUser item) {
    int index = _items.indexOf(
        _items.singleWhere((element) => element.userId == item.userId));
    _items[index] = item;
    update();
  }

  //Future<void> listenState() async {
  //  List<UserPhone> phones = [];
//
  //  for (var item in _items) {
  //    if (!phones.any((element) => element == item.phone)) {}
  //  }
  //  for (var phone in phones) {
  //    if (!_items.any((element) => element.phone == phone)) {
  //      ConversationUser? contactUser = await ConversationUser.withPhone(phone);
  //      if (contactUser != null) {
  //        _items.add(contactUser);
  //      }
  //    } else {
  //      String name = "";
  //      ConversationUser contactUser =
  //          _items.singleWhere((element) => element.phone == phone);
  //      if (name != contactUser.name) {
  //        contactUser.updateContactName(name);
  //      }
  //    }
  //  }
  //}
}
