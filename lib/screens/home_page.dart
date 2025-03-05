import 'dart:async';

import 'package:env_manager_app/services/instance_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import '../widgets/form_switch.dart';
import '../services/beer_service.dart';
import '../services/instances_status.dart';

import '../utils/turn_on_actions.dart';
import '../utils/turn_off_actions.dart';
import '../utils/chayanne_phrases.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool phraseVisible = false;
  bool beerVisible = false;
  Map<String, dynamic>? filteredBeer;
  var phraseIndex = 0;
  Map<String, dynamic>? instanceInformation;

  final BeerService _beerService = BeerService();
  final InstancesStatusService _statusService = InstancesStatusService();
  final InstanceManagerService _instanceManagerService = InstanceManagerService();

  int _counter = 0;
  String? _loggedUser;

  bool _giteaActive = false;
  bool _giteaUpdating = false;
  String _giteaStatusMessage = "Fetching gitea status...";

  bool _runnerActive = false;
  bool _runnerUpdating = false;
  String _runnerStatusMessage = "Fetching runner status...";

  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _loginCounter();
    _instanceStatus();
  }

  Future<void> _instanceStatus() async {
    setState(() {
      _refreshing = true;
    });
    final status = await _statusService.fetchStatus();
    final String runnerInitialStatus = status['instances'].firstWhere(
        (instance) => instance["name"] == "runner-server-prod")['state'];
    final String giteaInitialStatus = status['instances'].firstWhere(
        (instance) => instance["name"] == "gitea-server-prod")['state'];
    setState(() {
      _runnerStatusMessage = 'Name: runner-server-prod | Status: $runnerInitialStatus';
      _runnerActive = runnerInitialStatus == 'running' ? true : false;

      _giteaActive = giteaInitialStatus == 'running' ? true : false;
      _giteaStatusMessage = 'Name: gitea-server-prod | Status: $giteaInitialStatus';

      _refreshing = false;
    });
  }

  Future<void> _loginCounter() async {
    // Load and obtain the shared preferences for this app.
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedUser = prefs.getString("user");
      _counter =
          (prefs.getInt('counter_${_loggedUser?.toLowerCase()}') ?? 0) + 1;
      prefs.setInt('counter_${_loggedUser?.toLowerCase()}', _counter);
    });
  }

  Future<void> _resetCounter() async {
    // Load and obtain the shared preferences for this app.
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedUser = prefs.getString("user");
      _counter = 0;
      prefs.setInt('counter_${_loggedUser?.toLowerCase()}', _counter);
    });
  }

  _beerProvider(bool enabled) async {
    if (enabled == true) {
      final beerData = await _beerService.fetchBeer();
      setState(() {
        filteredBeer = beerData;
        beerVisible = true;
      });
    } else {
      setState(() {
        beerVisible = false;
      });
      //print("Turn off API connection");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(16.0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black),
                children: <TextSpan>[
                  const TextSpan(
                    text: 'What’s up? ',
                  ),
                  TextSpan(
                    text: _loggedUser,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: Text(
                    'Check instance status:',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _instanceStatus(),
                  icon: _refreshing
                    ? const SizedBox( width: 18, height: 18,child: CircularProgressIndicator(strokeWidth: 3, color: Colors.green))
                    : const Icon(Icons.refresh, size: 14),
                  label: const Text(
                    'Refresh',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
            value: _giteaActive,
            title: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Git Server'),
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10.0),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: _giteaUpdating
                            ? const CircularProgressIndicator(strokeWidth: 3, color: Colors.green)
                            : const Icon(Icons.dns_outlined, size: 20),
                      ),
                    ),
                    Text(_giteaStatusMessage, style: const TextStyle(fontSize: 12, color: Colors.black))
                  ],
                )
              ],
            ),
            onChanged: _giteaUpdating
              ? null
              : (bool enabled) async {
                setState(() {
                  _giteaActive = enabled;
                  _giteaUpdating = true;
                });
                if (await _instanceManagerService.actionsHandler(
                  'https://sm.andor.cloud/api/service_manager',
                  'gitea',
                  enabled ? turnOnActions : turnOffActions,
                  (msg) {
                    setState(() {
                      _giteaStatusMessage = msg;
                    });
                  },
                )) {
                  setState(() {
                    _giteaStatusMessage = 'Name: gitea-server-prod | Status:  ${_giteaActive ? "running" : "stopped"}';
                    _giteaUpdating = false;
                  });
                }
            },
            activeColor: Colors.green,
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
            value: _runnerActive,
            title: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Runner'),
                ),
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10.0),
                      child: SizedBox(
                          width: 18,  // Set width
                          height: 18, // Set height
                          child: _runnerUpdating
                              ? const CircularProgressIndicator(strokeWidth: 3, color: Colors.green)
                              : const Icon(Icons.dns_outlined, size: 20)
                      ),
                    ),
                    Text(_runnerStatusMessage, style: const TextStyle(fontSize: 12, color: Colors.black))
                  ],
                ),
              ],
            ),
            onChanged: _runnerUpdating
              ? null
              : (bool enabled) async {
                  setState(() {
                  _runnerActive = enabled;
                  _runnerUpdating = true;
                });
                if (await _instanceManagerService.actionsHandler(
                  'https://sm.andor.cloud/api/service_manager',
                  'runner',
                  enabled ? turnOnActions : turnOffActions,
                  (msg) {
                    setState(() {
                      _runnerStatusMessage =
                          msg; // Updates the UI when the status changes
                    });
                  },
                )) {
                  setState(() {
                    _runnerStatusMessage = 'Name: runner-server-prod | Status:  ${_runnerActive ? "running" : "stopped"}';
                    _runnerUpdating = false;
                  });
                }
              },
            activeColor: Colors.green,
          ),
          FormSwitch(label: 'Beer recommendation', onChange: _beerProvider),
          Visibility(
            visible: beerVisible,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.grey[200],
              child: filteredBeer == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Name: ${filteredBeer!['name']}\n'
                          'Price: ${filteredBeer!['price']}\n',
                          style: const TextStyle(fontSize: 18),
                        ),
                        Image.network(filteredBeer!['image']),
                      ],
                    ),
            ),
          ),
          FormSwitch(
            label: "Chayanne's Wisdom Phrase",
            onChange: (bool enabled) {
              if (enabled == true) {
                setState(() {
                  phraseIndex = Random().nextInt(12);
                });
              }
              setState(() {
                phraseVisible = enabled;
              });
            },
          ),
          const SizedBox(height: 10),
          Visibility(
              visible: phraseVisible,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.grey[200],
                    child: Text(
                      chayannePhrases[phraseIndex],
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  const SizedBox(height: 5),
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.restart_alt),
                    onPressed: () {
                      setState(() {
                        phraseIndex = Random().nextInt(12);
                      });
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
