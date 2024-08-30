import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  // List of allowed users
  static const List<String> allowedUsers = [
    "Isaac",
    "Karen",
    "Alfonso",
    "Moneda"
  ];

  // Function to check if the user credentials are valid
  bool isValidUser(String username, String password) {
    return allowedUsers.contains(username) && password == "ubiqus";
  }

  // Function to save the user to SharedPreferences
  Future<void> setUser(String user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', user);
  }
}