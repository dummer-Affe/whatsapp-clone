import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phone_number/phone_number.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart' as flutter_contacts;
import 'package:libphonenumber/libphonenumber.dart' as libphonenumber;
import 'package:whatsapp_clone/functions/functions.dart';
import '../../main.dart';
import 'contact.dart';
import 'phone.dart';
import 'user_privacy.dart';

class ConversationUser extends GetxController {
  late String _userId;
  late String _name;
  late UserPhone _phone;
  late String? _contactName;
  late String? _profilePhotoUrl;
  late String? _about;
  late List<Contact> _contacts;
  late UserPrivacy _privacyChoices;
  String get userId => this._userId;

  String get name => this._name;

  UserPhone get phone => this._phone;

  String? get contactName => this._contactName;

  String? get profilePhotoUrl => this._profilePhotoUrl;

  String? get about => this._about;

  List<Contact> get contacts => this._contacts;

  UserPrivacy get privacyChoices => this._privacyChoices;

  ConversationUser(
      {required String userId,
      required String name,
      required UserPhone phone,
      required String? profilePhotoUrl,
      required String? about,
      required List<Contact> contacts,
      required UserPrivacy privacyChoices}) {
    _privacyChoices = privacyChoices;
    _userId = userId;
    _name = name;
    _phone = phone;
    _profilePhotoUrl = profilePhotoUrl;
    _about = about;
    _contacts = contacts;
    getContactName();
    contactState.addListener(listenContactState);
    listenUser();
    listenUserContacts();
  }

  void listenContactState() {
    getContactName();
    update();
  }

  void getContactName() {
    if (contactState.items.any((element) => element.e164 == _phone.e164)) {
      _contactName = contactState.items
          .singleWhere((element) => element.e164 == _phone.e164)
          .name;
    } else {
      _contactName = _phone.e164;
    }
  }

  static Future<ConversationUser?> withPhone(UserPhone phone) async {
    var snapshot = await firestore
        .collection("users")
        .where("countryCode", isEqualTo: phone.countryCode)
        .where("nationalNumber", isEqualTo: phone.nationalNumber)
        .get();
    if (snapshot.size == 1) {
      return await ConversationUser.withDocument(snapshot.docs[0]);
    } else {
      return null;
    }
  }

  static Future<ConversationUser?> withId(String id) async {
    var snapshot = await firestore.collection("users").doc(id).get();
    if (snapshot.exists) {
      return (await ConversationUser.withDocument(snapshot));
    } else {
      return null;
    }
  }

  void listenUser() {
    firestore
        .collection("users")
        .doc(_userId)
        .snapshots()
        .listen((snapshot) async {
      onUpdate(snapshot);
    });
  }

  void listenUserContacts() {
    firestore
        .collection("users")
        .doc(_userId)
        .collection("contacts")
        .snapshots()
        .listen((snapshot) async {
      onUpdateContact(snapshot);
    });
  }

  Map<String, dynamic> toMap() {
    return {
      'name': _name,
      'countryCode': _phone.countryCode,
      'nationalNumber': _phone.nationalNumber,
      'profilePhotoUrl': _profilePhotoUrl,
      'about': _about,
      'privacyChoices': _privacyChoices.toMap(),
    };
  }

  static Future<ConversationUser> withDocument(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    Map<String, dynamic> data = snapshot.data()!;
    return ConversationUser(
      userId: snapshot.id,
      name: data['name'] as String,
      phone: UserPhone(
          nationalNumber: data['nationalNumber'] as String,
          countryCode: data['countryCode'] as String),
      profilePhotoUrl: data['profilePhotoUrl'] as String?,
      about: data['about'] as String,
      contacts: await getContacts(snapshot.id),
      privacyChoices: UserPrivacy.fromMap(data['privacy']),
    );
  }

  Future<void> fromDocument(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    Map<String, dynamic> data = snapshot.data()!;
    _userId = snapshot.id;
    _name = data['name'] as String;
    _phone = UserPhone(
        nationalNumber: data['nationalNumber'] as String,
        countryCode: data['countryCode'] as String);
    _profilePhotoUrl = data['profilePhotoUrl'];
    _about = data['about'] as String;
    _contacts = await getContacts(_userId);
    _privacyChoices = UserPrivacy.fromMap(data['privacy']);
  }

  Future<void> onUpdate(DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    Map<String, dynamic> data = snapshot.data()!;
    _userId = snapshot.id;
    _name = data['name'] as String;
    _phone = UserPhone(
        nationalNumber: data['nationalNumber'] as String,
        countryCode: data['countryCode'] as String);
    _profilePhotoUrl = data['profilePhotoUrl'];
    _about = data['about'] as String;
    _privacyChoices = UserPrivacy.fromMap(data['privacy']);
    update();
  }

  Future<void> onUpdateContact(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    List<Contact> contacts = [];
    snapshot.docs.forEach((element) {
      contacts.add(Contact.fromDocument(element));
    });
    _contacts = contacts;
    update();
  }

  static Future<List<Contact>> getContacts(String userId) async {
    List<Contact> contacts = [];
    await firestore
        .collection("users")
        .doc(userId)
        .collection("contacts")
        .get()
        .then((value) => value.docs.forEach((element) {
              contacts.add(Contact.fromDocument(element));
            }));
    return contacts;
  }

  String toJson() => json.encode(toMap());

  @override
  void dispose() {
    contactState.removeListener(listenContactState);
    super.dispose();
  }
}
