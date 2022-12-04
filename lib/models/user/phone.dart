class UserPhone {
  String nationalNumber;
  String countryCode;

  UserPhone({required this.nationalNumber, required this.countryCode});

  String get e164 {
    return "+$countryCode$nationalNumber";
  }
}
