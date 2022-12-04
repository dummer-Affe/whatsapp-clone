import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:phone_number/phone_number.dart';
import 'package:whatsapp_clone/main.dart';

class Contact {
  String name;
  String nationalNumber;
  String countryCode;
  late String international;

  String get e164 {
    return "+$countryCode$nationalNumber";
  }


  Contact(
      {required this.name,
      required this.countryCode,
      required this.nationalNumber}) {
    international = FlutterLibphonenumber().formatNumberSync(e164);
      }


  factory Contact.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> document) {
    return Contact(
        name: document.data()!["name"],
        countryCode: document.data()!["countryCode"],
        nationalNumber: document.data()!["nationalNumber"]);
  }

  

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'countryCode': countryCode,
      'nationalNumber': nationalNumber,
    };
  }

  Future<void> checkUpdate() async {
    DocumentSnapshot<Map<String, dynamic>>? doc = await _checkName();
    if (doc != null) {
      if (doc.data()!['nationalNumber'] != nationalNumber ||
          doc.data()!['countryCode'] != countryCode) {
        await doc.reference.update(
            {"nationalNumber": nationalNumber, "countryCode": countryCode});
      }
    } else {
      doc = await _checkPhone();
      if (doc != null) {
        if (doc.data()!['name'] != name) {
          await doc.reference.update({"name": name});
        }
      } else {
        await firestore
            .collection("users")
            .doc(userState.userId)
            .collection("contacts")
            .add(toMap());
      }
    }
  }

  Future<void> delete() async {
    var snapshot = await firestore
        .collection("users")
        .doc(userState.userId)
        .collection("contacts")
        .where("name", isEqualTo: name)
        .where("nationalNumber", isEqualTo: nationalNumber)
        .where("countryCode", isEqualTo: countryCode)
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _checkName() async {
    var snapshot = await firestore
        .collection("users")
        .doc(userState.userId)
        .collection("contacts")
        .where("name", isEqualTo: name)
        .get();
    return snapshot.size == 0 ? null : snapshot.docs[0];
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> _checkPhone() async {
    var snapshot = await firestore
        .collection("users")
        .doc(userState.userId)
        .collection("contacts")
        .where("nationalNumber", isEqualTo: nationalNumber)
        .where("countryCode", isEqualTo: countryCode)
        .get();
    return snapshot.size == 0 ? null : snapshot.docs[0];
  }
}
