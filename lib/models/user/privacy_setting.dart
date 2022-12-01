import 'dart:convert';

class PrivacySetting {
  late String _allowedUsers;
  late List<String> _exceptions;
  late List<String> _only;

  String get allowedUsers => this._allowedUsers;

  List<String> get exceptions => this._exceptions;

  List<String> get only => this._only;

  PrivacySetting({
    required String allowedUsers,
    List<String> exceptions = const [],
    List<String> only = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'allowed': _allowedUsers,
      'except': _exceptions,
      'only': _only,
    };
  }

  factory PrivacySetting.fromMap(Map<String, dynamic> map) {
    return PrivacySetting(
      allowedUsers: map['allowed'] as String,
      exceptions:
          map['except'] != null ? List<String>.from(map['except']) : const [],
      only: map['only'] != null ? List<String>.from(map['only']) : const [],
    );
  }

  bool checkPrivacy(String userId, List<String> contacts) {
    switch (allowedUsers) {
      case "everyone":
        return true;
      case "nobody":
        return false;
      case "contacts":
        if (_only.isNotEmpty) {
          return _only.any((element) => element == userId);
        } else if (_exceptions.isNotEmpty) {
          List<String> contactsTmp = contacts.map((e) => e).toList();
          contactsTmp.removeWhere((element) =>
              _exceptions.any((exception) => exception == element));
          return contactsTmp.any((element) => element == userId);
        } else {
          return contacts.any((element) => element == userId);
        }
      default:
        return false;
    }
  }

  String toJson() => json.encode(toMap());

  factory PrivacySetting.fromJson(String source) =>
      PrivacySetting.fromMap(json.decode(source));
}
