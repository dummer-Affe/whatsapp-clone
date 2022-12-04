import 'dart:convert';

import 'privacy_setting.dart';

class UserPrivacy {
  late PrivacySetting _about;
  late PrivacySetting _lastSeen;
  late PrivacySetting _online;
  late PrivacySetting _profilePhoto;
  late PrivacySetting _status;
  
  PrivacySetting get about => _about;


  PrivacySetting get lastSeen => _lastSeen;


  PrivacySetting get online => _online;


  PrivacySetting get profilePhoto => _profilePhoto;


  PrivacySetting get status => _status;

  UserPrivacy({
    required PrivacySetting about,
    required PrivacySetting lastSeen,
    required PrivacySetting online,
    required PrivacySetting profilePhoto,
    required PrivacySetting status,
  }) {
    _about = about;
    _lastSeen = lastSeen;
    _online = online;
    _profilePhoto = profilePhoto;
    _status = status;
  }

  Map<String, dynamic> toMap() {
    return {
      'about': _about.toMap(),
      'last_seen': _lastSeen.toMap(),
      'online': _online.toMap(),
      'profile_photo': _profilePhoto.toMap(),
      'status': _status.toMap(),
    };
  }

  factory UserPrivacy.fromMap(Map<String, dynamic> map) {
    return UserPrivacy(
      about: PrivacySetting.fromMap(map['about']),
      lastSeen: PrivacySetting.fromMap(map['last_seen']),
      online: PrivacySetting.fromMap(map['online']),
      profilePhoto: PrivacySetting.fromMap(map['profile_photo']),
      status:  PrivacySetting.fromMap(map['status']),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserPrivacy.fromJson(String source) => UserPrivacy.fromMap(json.decode(source));
}
