import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/instances_status.dart';

class InstanceManagerService {
  final InstancesStatusService _statusService = InstancesStatusService();
  Future<bool> actionsHandler(
      String url,
      String instanceName,
      List<Map<String, dynamic>> actions,
      Function(String) updateStatusMessage) async {
    final status = await _statusService.fetchStatus();
    List<dynamic> instances = status['instances'];
    Map<String, dynamic> instance = instances
        .firstWhere((instance) => instance["name"].contains(instanceName));

    // print("instance:");
    // print(instance);

    final instanceId = instance['id'];
    // print("instanceId:");
    // print(instanceId);
    // print("------------------------------------------");

    // If instance is in the desire state the abort actions and return true.
    if ((instance["state"] == 'stopped' &&
            actions[0]['action'] == 'turn-off') ||
        (instance["state"] == 'running' &&
            actions[0]['action'].contains('create'))) {
      // The instance state is in the desire state.
      updateStatusMessage('${instance['name']} | Status: ${instance["state"]}');
      return true;
    }

    List<dynamic> instanceVolumes = instance['volumes'];

    // print("Volumes:");
    // print(instanceVolumes);
    // print("------------------------------------------");

    // Creating a copy of the actions before modify the actions based on the instamce currrent status.
    List<Map<String, dynamic>> filteredActions =
        actions.map((action) => Map<String, dynamic>.from(action)).toList();

    if (instance['state'] == 'stopped') {
      if (instanceVolumes.length == 2) {
        // The instance is down but the volumes are attached, only "turn-on" is required.
        //print("2 volumes attached only turn-on required ");
        filteredActions = filteredActions
            .where((action) => action["action"] == "turn-on")
            .toList();
      } else if (instanceVolumes.length == 1) {
        // Check if any volume contains 'root'
        // print("One volume attached, verifying if it is root or data");
        // print(" is root: ${instanceVolumes[0]["volume_name"].contains('root')}");
        final matchRoot = instanceVolumes[0]["volume_name"].contains('root');
        // print(matchRoot ? "is root volume" : "is data volume");
        // print("Removing ${matchRoot ? 'root' : 'data'} actions");
        // Remove actions based on whether a "root" volume exists
        filteredActions.removeWhere(
            (item) => item['action'].contains(matchRoot ? 'root' : 'data'));
      }
    }

    // print("actions");
    // print(filteredActions);
    // print("------------------------------------------");

    for (int i = 0; i < filteredActions.length; i++) {
      final action = filteredActions[i];
      bool success = false; // Flag to track if the action succeeded
      String? volId;

      actionLoop:
      for (int attempt = 1; attempt <= action['attempts']; attempt++) {
        try {
          // Execute the POST request
          updateStatusMessage('Attempt to execute ${action["action"]} action');
          //print('Attempt to execute ${action["action"]} action');
          final result = await actionResolver(
              url, instanceName, action['action'], null, null);

          if (result["succeed"]) {
            // print("succeed result:");
            // print(result);

            // List of keywords to check
            List<String> keywords = ['create', 'atach', 'snapshot'];

            // Check if any of the keywords are in the action string
            bool containsAny = keywords
                .any((keyword) => action['action']?.contains(keyword) ?? false);

            // If the executed action was create-vol, it is required to get the ID fo the created vol.
            if (containsAny) {
              // print('${action['action']} getting volume ID');
              // print(result);
              volId = result["responseData"]
                  [action["pass_condition"]['resource_id']];
              // print("Volume ID");
              // print(volId);
            }

            // verify if pass condition is required.
            if (action.containsKey("pass_condition")) {
              // print("Needs resolve pass_condition:");

              for (int attempt = 1;
                  attempt <= action["pass_condition"]['attempts'];
                  attempt++) {
                String elId = volId ?? instanceId;

                if (action['action'].contains('detach')) {
                  bool isRoot = action['action'] == "detach-root";
                  //print('Detach ${isRoot ? "root" : "data"} volume');
                  Map volInstance = instanceVolumes.firstWhere((volume) =>
                      volume["volume_name"].contains(isRoot ? 'root' : 'data'));
                  // print("volume instance to detach:");
                  // print(volInstance);

                  elId = volInstance["volume_id"];
                }

                //print("element ID");
                //print(elId);

                try {
                  final conditionResult = await actionResolver(
                      url,
                      instanceName,
                      action["pass_condition"]['action'],
                      elId,
                      action["pass_condition"]['response_value']);
                  // print("conditionResult:");
                  // print(conditionResult);
                  // print("------------------------------------------");
                  if (conditionResult["succeed"]) {
                    // print("succeed conditionResult:");
                    // print(conditionResult);
                    // print("breaking on success conditionResult");
                    // print("------------------------------------------");
                    success = true; // Mark success if the POST succeeds
                    if (i == filteredActions.length - 1) {
                      //print('last action ${action["action"]} executed');
                    }
                    break actionLoop;
                  }
                } catch (e) {
                  updateStatusMessage(
                      'Error during attempt $attempt for action ${action["pass_condition"]["action"]}: $e');
                  //print('Error during attempt $attempt for action $action: $e');
                }

                // Wait for the specified time before retrying, except after the last attempt
                if (attempt < action["pass_condition"]['attempts']) {
                  await Future.delayed(
                      Duration(seconds: action["pass_condition"]['timeout']));
                }
              }
            } else {
              success = true; // Mark success if the POST succeeds
              //print("breaking on success action ${action["action"]}");
              if (i == filteredActions.length - 1) {
                //print('last action ${action["action"]} executed');
              }
              //print("------------------------------------------");
              break actionLoop; // Exit retry loop if successful
            }
          }
        } catch (e) {
          updateStatusMessage(
              'Error during attempt $attempt for action ${action["action"]}: $e');
          //print('Error during attempt $attempt for action ${action["action"]}: $e');
        }

        // Wait for the specified time before retrying, except after the last attempt
        if (attempt < action['attempts']) {
          await Future.delayed(Duration(seconds: action['timeout']));
        }
      }

      // Handle the case where all attempts fail
      if (!success) {
        updateStatusMessage(
            'Failed to execute action ${action["action"]}, stopping execution.');
        //print('Failed to execute action ${action["action"]}, stopping execution.');
        return false; // Stop execution if any action fails
      }
    }
    // If all actions succeed, return true
    return true;
  }

  Future<Map<String, dynamic>> actionResolver(String url, String instance,
      String action, String? resourceId, String? conditionVal) async {
    final uri = Uri.parse(url);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final basicAuth = 'Bearer $token';

    Map<String, String?> requestBody = resourceId != null
        ? {"action": action, "resource_id": resourceId}
        : {
            "action": action,
            "instance": instance,
          };

    final response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': basicAuth,
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      print(response.body);
      print(response.headers);
      print(response.request);
    }

    // Parse response body
    final Map<String, dynamic> responseData = jsonDecode(response.body);

    return {
      "succeed": response.statusCode == 200 &&
          (conditionVal == null || responseData["status"] == conditionVal),
      "responseData": responseData
    };
  }
}
