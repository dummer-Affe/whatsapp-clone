import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phone_number/phone_number.dart';
import 'package:get/get.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:libphonenumber/libphonenumber.dart' as libphonenumber;
import '/functions/functions.dart';
import '../../main.dart';
import 'phone.dart';
import 'user_privacy.dart';

class ConversationUser extends GetxController {
  late String _userId;
  late String _name;
  late UserPhone _phone;
  late String? _contactName;
  late String? _profilePhotoUrl;
  late String? _about;
  late List<String> _contacts;
  late UserPrivacy _privacyChoices;
  get userId => this._userId;

  get name => this._name;

  UserPhone get phone => this._phone;

  get contactName => this._contactName;

  get profilePhotoUrl => this._profilePhotoUrl;

  get about => this._about;

  get contacts => this._contacts;

  get privacyChoices => this._privacyChoices;

  ConversationUser(
      {required String userId,
      required String name,
      required UserPhone phone,
      required String? contactName,
      required String? profilePhotoUrl,
      required String? about,
      required List<String> contacts,
      required UserPrivacy privacyChoices}) {
    _privacyChoices = privacyChoices;
    _userId = userId;
    _name = name;
    _phone = phone;
    _contactName = contactName;
    _profilePhotoUrl =
        _privacyChoices.profilePhoto.checkPrivacy(userId, contacts)
            ? profilePhotoUrl
            : null;
    _about =
        _privacyChoices.about.checkPrivacy(userId, contacts) ? about : null;
    _contacts = contacts;
    listenUser();
  }

  static Future<ConversationUser?> withPhone(UserPhone phone) async {
    var snapshot = await firestore
        .collection("users")
        .where("phoneCountryCode", isEqualTo: phone.countryCode)
        .where("phoneNum", isEqualTo: phone.number)
        .get();
    if (snapshot.size == 1) {
      return ConversationUser.fromDocument(snapshot.docs[0]);
    } else {
      return null;
    }
  }

  static Future<ConversationUser?> withId(String id) async {
    var snapshot = await firestore.collection("users").doc(id).get();
    if (snapshot.exists) {
      return ConversationUser.fromDocument(snapshot);
    } else {
      return null;
    }
  }

  void listenUser() {
    listenContacts();
    firestore.collection("users").doc(_userId).snapshots().listen((snapshot) {
      fromDocument(snapshot);
      update();
    });
  }

  void listenContacts() {
    FlutterContacts.addListener(() async {
      matchPhoneFromContacts();
    });
  }

  Future<void> matchPhoneFromContacts() async {
    List<Contact> contacts = await FlutterContacts.getContacts();
    for (var contact in contacts) {
      PhoneNumber? phoneNumber = await getNumberOfContact(contact);
      if (phoneNumber != null &&
          phoneNumber.national == phone.number &&
          phoneNumber.countryCode == phone.countryCode) {
        await updateContactName(contact.displayName);
      }
    }
    update();
  }

  Future<List<UserPhone>> getContactPhones() async {
    List<Contact> contacts = await FlutterContacts.getContacts();
    List<UserPhone> phones = [];
    for (var contact in contacts) {
      PhoneNumber? phoneNumber = await getNumberOfContact(contact);
      if (phoneNumber != null) {
        phones.add(UserPhone(
            number: phoneNumber.nationalNumber,
            countryCode: phoneNumber.countryCode));
      }
    }
    return phones;
  }

  Future<void> updateContactName(String name) async {
    if (_contactName != name) {
      _contactName = name;
      await updateItem();
    }
  }

  Future<void> saveItem() async {
    await firestore.collection("users").doc(_userId).set(toMap());
  }

  Future<void> updateItem() async {
    await firestore.collection("users").doc(_userId).update(toMap());
    update();
  }

  Future<void> delete() async {
    conversationUserState.removeItem(this);
    await firestore.collection("users").doc(_userId).delete();
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': _userId,
      'name': _name,
      'phoneCountryCode': _phone.countryCode,
      'phoneNum': _phone.number,
      'contactName': _contactName,
      'profilePhotoUrl': _profilePhotoUrl,
      'about': _about,
      'contacts': _contacts,
      'privacyChoices': _privacyChoices.toMap(),
    };
  }

  factory ConversationUser.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    return ConversationUser(
      userId: snapshot.id,
      name: data['name'] as String,
      phone: UserPhone(
          number: data['phoneNum'] as String,
          countryCode: data['phoneCountryCode'] as String),
      profilePhotoUrl: data['profilePhotoUrl'] as String?,
      contactName: data['contactName'] as String,
      about: data['about'] as String,
      contacts: List<String>.from(data['contacts']),
      privacyChoices: UserPrivacy.fromMap(data['privacy']),
    );
  }

  void fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> data = snapshot.data()!;
    _userId = snapshot.id;
    _name = data['name'] as String;
    _phone = UserPhone(
        number: data['phoneNum'] as String,
        countryCode: data['phoneCountryCode'] as String);
    _profilePhotoUrl = data['profilePhotoUrl'];
    _contactName = data['contactName'] as String;
    _about = data['about'] as String;
    _contacts = List<String>.from(data['contacts']);
    _privacyChoices = UserPrivacy.fromMap(data['privacy']);
  }

  String toJson() => json.encode(toMap());

  factory ConversationUser.fromJson(String source) =>
      ConversationUser.fromDocument(json.decode(source));
}
