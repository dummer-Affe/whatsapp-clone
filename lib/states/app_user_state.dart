import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whatsapp_clone/models/user/contact.dart';
import '../models/chat/group_chat.dart';
import '../models/user/phone.dart';
import '../models/user/privacy_setting.dart';
import '../models/user/conversation_user.dart';
import '../models/user/user_privacy.dart';
import '../main.dart';
import 'contact_state.dart';
import 'conversation_state.dart';
import 'conversation_user_state.dart';

class AppUserState extends GetxController {
  User? _authUser;
  String? _userId;
  String? _name;
  UserPhone? _phone;
  String? _profilePhotoUrl;
  String? _about;
  UserPrivacy? _privacyChoices;

  User? get authUser => _authUser;

  String? get userId => _userId;

  String? get name => _name;

  UserPhone? get phone => _phone;

  String? get profilePhotoUrl => _profilePhotoUrl;

  String? get about => _about;

  UserPrivacy? get privacyChoices => _privacyChoices;

  Future<void> signIn(User user) async {
    _authUser = user;
    await getUser(user.uid);
    await setupStates();
    listenUser();
  }

  setupStates() async {
    conversationUserState = Get.put(ConversationUserState());
    conversationState = Get.put(ConversationState());
    contactState = Get.put(ContactState());
    await contactState.setup();
    await conversationState.setupConversations();
  }

  void listenUser() {
    firestore.collection("users").doc(_userId).snapshots().listen((snapshot) {
      fromDocument(snapshot);
    });
  }

  Future<void> getUser(String userId) async {
    var doc = await firestore.collection("users").doc(userId).get();
    if (doc.exists) {
      fromDocument(doc);
    } else {
      String authPhone = _authUser!.phoneNumber!;
      var phone = await FlutterLibphonenumber().parse(authPhone);
      String countryCode = phone["countryCode"];
      String nationalNumber = authPhone.replaceFirst("+$countryCode", "");
      PrivacySetting everyone = PrivacySetting(allowedUsers: "everyone");
      PrivacySetting contacts = PrivacySetting(allowedUsers: "contacts");
      UserPrivacy privacy = UserPrivacy(
          about: everyone,
          lastSeen: everyone,
          online: everyone,
          profilePhoto: everyone,
          status: contacts);
      await firestore.collection("users").doc(userId).set({
        "about": "",
        "name": "",
        "countryCode": countryCode,
        "nationalNumber": nationalNumber,
        "profilePhotoUrl": null,
        "userPrivacy": privacy.toMap()
      });
      _name = "";
      _phone =
          UserPhone(nationalNumber: nationalNumber, countryCode: countryCode);
      _about = "";
      _privacyChoices = privacy;
      _profilePhotoUrl = null;
    }
  }

  void fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> map = snapshot.data()!;
    _userId = snapshot.id;
    _name = map['name'] as String;
    _phone = UserPhone(
        nationalNumber: map['nationalNumber'] as String,
        countryCode: map['countryCode'] as String);
    _about = map['about'] as String;
    _privacyChoices = UserPrivacy.fromMap(map['privacy']);
    _profilePhotoUrl = map['profilePhotoUrl'] as String?;
  }

  bool isMyPhone(String nationalNumber, String countryCode) {
    return nationalNumber == _phone!.nationalNumber &&
        countryCode == _phone!.countryCode;
  }
}
