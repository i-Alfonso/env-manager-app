import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginService {
  // List of allowed users
  static const List<String> allowedUsers = [
    "Isaac",
    "Karen",
    "Alfonso",
    "Moneda"
  ];

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('https://auth.andor.cloud/oauth2/token');
    final basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': basicAuth,
      },
      body: {
        'grant_type': 'client_credentials',
        'scope': 'andorcsm-report-rs-server/andorcsm-report',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', data["access_token"]);
      return true;
    } else {
      return false;
    }
  }

  // Function to check if the user credentials are valid
  Future<bool> isValidUser(String username, String password) async {
    if(allowedUsers.contains(username) && password == "ubiqus") {
      return await login('68f2k40ql37bn1o21cdaa4a7af', 'ptol7hjvvqgsd1pe9h7ri143rqpv9o06q8ritp48oaoj0el57ca');
    } else {
      return false;
    }
  }

  // Function to save the user to SharedPreferences
  Future<void> setUser(String user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', user);
  }

  Future<String?> checkToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    return token;
  }
}