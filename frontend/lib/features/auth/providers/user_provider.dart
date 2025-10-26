import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final supabase = Supabase.instance.client;

class UserProvider with ChangeNotifier {
  String? id;
  String? name;
  String? surname;
  String? email;
  String? ageGroup;
  String? hardArea;
  String? readingGoal;
  String? diagnosisTime;
  String? motivatingGames;
  String? interests;
  String? workingWithProfessional;

  bool get isLoggedIn => id != null;

  void setUser(Map<String, dynamic> data) {
    id = data['id'];
    name = data['name'];
    surname = data['surname'];
    email = data['email'];
    ageGroup = data['age_group'];
    hardArea = data['hard_area'];
    readingGoal = data['reading_goal'];
    diagnosisTime = data['diagnosis_time'];
    motivatingGames = data['motivating_games'];
    interests = data['interests'];
    workingWithProfessional = data['working_with_professional'];
    notifyListeners();
  }

  Future<void> loadFromSupabase() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    setUser(response);
    await saveToLocal();
  }

  Future<void> saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', id ?? '');
    await prefs.setString('name', name ?? '');
    await prefs.setString('surname', surname ?? '');
    await prefs.setString('email', email ?? '');
    await prefs.setString('age_group', ageGroup ?? '');
    await prefs.setString('hard_area', hardArea ?? '');
    await prefs.setString('reading_goal', readingGoal ?? '');
    await prefs.setString('diagnosis_time', diagnosisTime ?? '');
    await prefs.setString('motivating_games', motivatingGames ?? '');
    await prefs.setString('interests', interests ?? '');
    await prefs.setString(
      'working_with_professional',
      workingWithProfessional ?? '',
    );
  }

  Future<void> loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getString('id');
    if (storedId == null || storedId.isEmpty) return;

    id = storedId;
    name = prefs.getString('name');
    surname = prefs.getString('surname');
    email = prefs.getString('email');
    ageGroup = prefs.getString('age_group');
    hardArea = prefs.getString('hard_area');
    readingGoal = prefs.getString('reading_goal');
    diagnosisTime = prefs.getString('diagnosis_time');
    motivatingGames = prefs.getString('motivating_games');
    interests = prefs.getString('interests');
    workingWithProfessional = prefs.getString('working_with_professional');
    notifyListeners();
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    await clear();
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    id = null;
    name = null;
    surname = null;
    email = null;
    ageGroup = null;
    hardArea = null;
    readingGoal = null;
    diagnosisTime = null;
    motivatingGames = null;
    interests = null;
    workingWithProfessional = null;
    notifyListeners();
  }
}
