import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RunnerManagerService {
  Future<bool> setRunnerState(action) async {
    final url = Uri.parse('https://sm.andor.cloud/api/service_manager');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final basicAuth = 'Bearer $token';
    final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': basicAuth,
        },
        body: jsonEncode({
          "action": action,
          "instance": "runner"
        })
    );
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      Map<String, dynamic> data = jsonDecode(response.body);
      return true;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to $action runner instance');
    }
  }
}