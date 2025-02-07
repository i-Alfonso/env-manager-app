import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class InstanceManagerService {

  Future<bool> actionsHandler(
      String url, String instanceName, int time, int attempts, List<String> actions, Function(String) updateStatusMessage, List<dynamic> instances)
  async {
    final Map<String, dynamic> instance = instances.firstWhere(
            (instance) => instance["name"].contains(instanceName));

    List<dynamic> instanceVolumes = instance['volumes'];

    if (instance['state'] == 'stopped') {
      if (instanceVolumes.length == 2) {
        // The instance is down but the volumes are attached, only "turn-on" is required.
        actions = ['turn-on'];
      } else {
        // Check if any volume contains 'root'
        final matchRoot = instanceVolumes.firstWhere(
              (volume) => volume["volume_name"].contains('root'),
          orElse: () => null,
        );

        // Remove actions based on whether a "root" volume exists
        if (matchRoot != null) {
          actions.removeWhere((item) => item.contains('root'));
        }
      }
    }

    for (int i = 0; i < actions.length; i++) {
      final action = actions[i];
      bool success = false; // Flag to track if the action succeeded

      for (int attempt = 1; attempt <= attempts; attempt++) {
        try {
          // Execute the POST request
          updateStatusMessage('Attempt to execute $action action');
          print('Attempt to execute $action action');
          final result = await actionResolver(url, instanceName, action);

          if (result) {
            success = true; // Mark success if the POST succeeds
            break; // Exit retry loop if successful
          }
        } catch (e) {
          updateStatusMessage('Error during attempt $attempt for action $action: $e');
          print('Error during attempt $attempt for action $action: $e');
        }

        // Wait for the specified time before retrying, except after the last attempt
        if (attempt < attempts) {
          await Future.delayed(Duration(seconds: time));
        }
      }

      // Handle the case where all attempts fail
      if (!success) {
        updateStatusMessage('Failed to execute action $action, stopping execution.');
        print('Failed to execute action $action, stopping execution.');
        return false; // Stop execution if any action fails
      }
    }
    // If all actions succeed, return true
    return true;
  }

  Future<bool> actionResolver(String url, String instance, String action) async {
    final uri = Uri.parse(url);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final basicAuth = 'Bearer $token';

    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': basicAuth,
      },
      body: jsonEncode({
        "action": action,
        "instance": instance,
      }),
    );

    print(jsonEncode({
      "action": action,
      "instance": instance,
    }));


    if(response.statusCode != 200) {
      print(response.body);
      print(response.headers);
      print(response.request);
    }

    return response.statusCode == 200;
  }
}