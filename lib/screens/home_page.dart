import 'dart:async';

import 'package:env_manager_app/services/runner_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

import '../widgets/form_switch.dart';
import '../services/beer_service.dart';
import '../services/instances_status.dart';

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
  final RunnerManagerService _runnerManagerService = RunnerManagerService();

  int _counter = 0;
  String? _loggedUser;


  bool _runnerActive = false;
  String _runnerStatusMessage = "Fetching runner status...";

  @override
  void initState() {
    super.initState();
    _loginCounter();
    _instanceStatus();
  }

  Future<void> _instanceStatus() async {
    final status = await _statusService.fetchStatus();
    print(status);
    setState(() {
      _runnerStatusMessage = 'Name: runner-server-prod | Status: ${status['instances'].firstWhere((instance) => instance["name"] == "runner-server-prod")['state']}';
    });
  }

  Future<void> _loginCounter() async {
    // Load and obtain the shared preferences for this app.
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedUser = prefs.getString("user");
      _counter = (prefs.getInt('counter_${_loggedUser?.toLowerCase()}') ?? 0) + 1;
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
    if(enabled == true) {
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

  static const chayannePhrases = [
    "\"Fuiste tanto y fuiste tan poco, así son las historias de locos\"",
    "\"Que si nos quedara poco tiempo, si mañana acaban nuestros días, \ny si no te he dicho suficiente, que te adoro con la vida\"",
    "\"Y tú te vas así como si nada, acortándome la vida, agachando la mirada\"",
    "\"De lunes a domingo voy desesperado, el corazón prendido allí en el calendario, \nbuscándote y buscando como un mercenario\"",
    "\"Si hay que ser torero poner el alma en el ruedo, no importa lo que se venga \npa' que sepas que te quiero\"",
    "\"pa' que sepas que te quiero, Como un buen torero (ole) me juego la vida por ti\"",
    "\"Que yo quiero ser tu alma, ser tu socio, ser tu amante, ser tu amigo, la mitad de tu destino.\"",
    "\"En palabras simples y comunes yo te extrañó, en lenguaje terrenal mi vida eres tú\"",
    "\"No tires piedras al vecino si de cristal es tu tejado\"",
    "\"Y, ¿qué me has hecho? que hasta perdí la razón\"",
    "\"Para tu tranquilidad me tienes en tus masnos, para mi debilidad la única eres tú\"",
    "\"Tú tienes el control de lo que pienso, de lo que imagino, \ntienes todo lo que quiero, lo que necesito.\""
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container (
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
          Container (
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text(
                    'You have signed in: $_counter times',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _resetCounter,
                  icon: const Icon(Icons.refresh,size: 14),
                  label: const Text('Reset', style: TextStyle(fontSize: 12),),
                ),
              ],
            ),
          ),
          const FormSwitch(label: 'Git Server'),
          const FormSwitch(label: 'CI/CD'),
          SwitchListTile(
            value: _runnerActive,
            title: const Text('Runner'),
            onChanged: (bool enabled) async {
              setState(() {
                _runnerActive = enabled;
              });
              if(await _runnerManagerService.setRunnerState(enabled ? "turn-on" : "turn-off")) {
                 _instanceStatus();
              } else {
                _runnerStatusMessage = "Error trying to ${enabled ? "turn-on" : "turn-off"} the runner";
                _runnerActive = !enabled;
              }
            },
            activeColor: Colors.green,
          ),
          Container(
            padding: const EdgeInsets.only(left:16.0, right: 16),
            child: Text(_runnerStatusMessage, style: const TextStyle(fontSize: 14))
          ),
          const FormSwitch(label: 'Non-prod'),
          FormSwitch(
              label: 'Beer recommendation',
              onChange: _beerProvider
          ),
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
            onChange: (bool enabled){
              if(enabled == true) {
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
              )
          ),
        ],
      ),
    );
  }
}