import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:phone_number/phone_number.dart';
import 'package:whatsapp_clone/models/user/conversation_user.dart';
import 'package:whatsapp_clone/models/user/phone.dart';
import 'package:whatsapp_clone/states/conversation_state.dart';

import '../functions/functions.dart';
import '../main.dart';
import '../models/user/contact.dart';

class ContactState extends GetxController {
  List<Contact> _items = [];
  List<Contact> _databaseItems = [];

  List<Contact> get items => _items;

  setup() async {
    print("lol");
    if (await Permission.contacts.request().isGranted) {
      await fetchFromDatabase();
      await fetchFromLocal();
      listenLocalContacts();
    }
  }

  void listenLocalContacts() {
    flutter_contacts.FlutterContacts.addListener(() async {
      fetchFromLocal();
    });
  }

  Future<void> fetchFromLocal() async {
    List<Contact> contacts = [];
    List<flutter_contacts.Contact> contactsLocal =
        await flutter_contacts.FlutterContacts.getContacts(withProperties: true);

    for (var contact in contactsLocal) {
      PhoneNumber? phoneNumber = await getNumberOfContact(contact);
      if (phoneNumber != null) {
        Contact item = Contact(
            name: contact.displayName,
            countryCode: phoneNumber.countryCode,
            nationalNumber: phoneNumber.nationalNumber);
        contacts.add(item);
      }
    }
    _items = contacts;
    checkContacts();
  }

  Future<void> checkContacts() async {
    for (var item in _items) {
      await item.checkUpdate();
    }
    await checkDatabaseItems();
  }

  Future<void> checkDatabaseItems() async {
    for (var item in _databaseItems) {
      if (!_items.any((element) => element == item)) {
        await item.delete();
      }
    }
  }

  Future<void> fetchFromDatabase() async {
    List<Contact> databaseItems = [];
    await firestore
        .collection("users")
        .doc(userState.userId)
        .collection("contacts")
        .get()
        .then((value) => value.docs.forEach((element) {
              databaseItems.add(Contact.fromDocument(element));
            }));
    _databaseItems = databaseItems;
  }

  static Future<String?> getUserIdFromPhone(UserPhone phone) async {
    if (conversationUserState.items.any((element) => element.phone == phone)) {
      return conversationUserState.items
          .singleWhere((element) => element.phone == phone)
          .userId;
    } else {
      var query = await firestore
          .collection("users")
          .where("nationalNumber", isEqualTo: phone.nationalNumber)
          .where("countryCode", isEqualTo: phone.countryCode)
          .get();
      if (query.size == 0) {
        return null;
      } else {
        var conversationUser = await ConversationUser.withPhone(phone);
        conversationUserState.addItem(conversationUser!);
        return query.docs.first.id;
      }
    }
  }
}
