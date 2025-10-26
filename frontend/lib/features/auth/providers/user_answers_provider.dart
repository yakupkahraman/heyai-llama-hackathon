import 'package:flutter/material.dart';

class UserAnswersProvider with ChangeNotifier {
  String? name;
  String? surname;
  String? email;
  String? password;

  Map<String, dynamic> answers = {};

  void setBasicInfo(String n, String s) {
    name = n;
    surname = s;
    notifyListeners();
  }

  void setEmailAndPassword(String e, String p) {
    email = e;
    password = p;
    notifyListeners();
  }

  void updateAnswer(String key, dynamic value) {
    answers[key] = value;
    notifyListeners();
  }

  Map<String, dynamic> getFullData() {
    return {'name': name, 'surname': surname, 'email': email, ...answers};
  }

  void clear() {
    name = null;
    surname = null;
    email = null;
    password = null;
    answers.clear();
    notifyListeners();
  }
}
