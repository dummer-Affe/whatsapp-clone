import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/chat/group_chat.dart';
import '../models/user/phone.dart';
import '../models/user/privacy_setting.dart';
import '../models/user/conversation_user.dart';
import '../models/user/user_privacy.dart';
import '../main.dart';

class AppUserState extends GetxController {
  User? _authUser;
  String? _userId;
  String? _name;
  UserPhone? _phone;
  String? _profilePhotoUrl;
  String? _about;
  List<String>? _contacts;
  UserPrivacy? _privacyChoices;

  User? get authUser => _authUser;

  String? get userId => _userId;

  String? get name => _name;

  UserPhone? get phone => _phone;

  String? get profilePhotoUrl => _profilePhotoUrl;

  String? get about => _about;

  List<String>? get contacts => _contacts;

  UserPrivacy? get privacyChoices => _privacyChoices;

  Future<void> signIn(User user) async {
    _userId = user.uid;
    listenUser();
    update();
  }

  Future<void> signInFake(String userId) async {
    _userId = userId;
    listenUser();
    update();
  }

  void listenUser() {
    firestore.collection("users").doc(_userId).snapshots().listen((snapshot) {
      fromDocument(snapshot);
      update();
    });
  }

  void fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic> map = snapshot.data()!;
    _userId = snapshot.id;
    _name = map['name'] as String;
    _phone = UserPhone(
        number: map['phoneNum'] as String,
        countryCode: map['phoneCountryCode'] as String); 
    _about = map['about'] as String;
    _contacts = List<String>.from(map['contacts']);
    _privacyChoices = UserPrivacy.fromMap(map['privacy']);
    _profilePhotoUrl = map['profilePhotoUrl'] as String?;
  }
}
