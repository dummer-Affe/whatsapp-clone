import 'dart:io';
import 'dart:math';
import 'package:flutter_contacts/contact.dart';
import 'package:libphonenumber/libphonenumber.dart' as libphonenumber;
import 'package:phone_number/phone_number.dart';
import 'package:whatsapp_clone/values/variables.dart';

const AUTO_ID_ALPHABET =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
const AUTO_ID_LENGTH = 20;
String getRandId() {
  final buffer = StringBuffer();
  final random = Random.secure();

  final maxRandom = AUTO_ID_ALPHABET.length;

  for (int i = 0; i < AUTO_ID_LENGTH; i++) {
    buffer.write(AUTO_ID_ALPHABET[random.nextInt(maxRandom)]);
  }
  return buffer.toString();
}

Future<PhoneNumber?> parsePhoneNumber(String number) async {
  PhoneNumber? phoneNumber;
  try {
    if (number.startsWith("+")) {
      phoneNumber = await PhoneNumberUtil().parse(number);
    } else if (number.startsWith("00")) {
      number = number.replaceFirst("00", "+");
      phoneNumber = await PhoneNumberUtil().parse(number);
    } else {
      String isoCode = await PhoneNumberUtil().carrierRegionCode();
      String? normalizedNumber =
          await libphonenumber.PhoneNumberUtil.normalizePhoneNumber(
              phoneNumber: number, isoCode: isoCode);

      phoneNumber = normalizedNumber != null
          ? await PhoneNumberUtil().parse(normalizedNumber)
          : null;
    }
    return phoneNumber;
  } catch (e) {
    return null;
  }
}

Future<PhoneNumber?> getNumberOfContact(Contact contact) async {
  print("phones:${contact}");
  for (var phone in contact.phones) {
    String number = phone.number;
    print("number:$number");
    PhoneNumber? phoneNumber = await parsePhoneNumber(number);
    if (phoneNumber != null) return phoneNumber;
  }
  return null;
}


