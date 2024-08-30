import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_page.dart';

void main() {
  runApp(
    const MaterialApp(
      home: LoginPage(),
    ),
  );
}

// class LoginPage extends StatelessWidget {
//   const LoginPage({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: DefaultTabController(
//         length: 2,
//         child: Scaffold(
//           appBar: AppBar(
//             title: const Text(
//               'Login',
//               style: TextStyle(color: Colors.white),
//             ),
//             backgroundColor: Colors.black,
//           ),
//           body: const LoginCard(),
//           backgroundColor: Colors.black,
//         ),
//       ),
//     );
//   }
// }
//
// // Login Card widget.
// class Home extends StatefulWidget {
//   const Home({super.key});
//
//   @override
//   State<Home> createState() => _HomeState();
// }
//
// class _HomeState extends State<Home> {
//
//   bool phraseVisible = false;
//   bool beerVisible = false;
//   Map<String, dynamic>? filteredBeer;
//   var phraseIndex = 0;
//
//   int _counter = 0;
//   String? _loggedUser = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _loginCounter();
//   }
//
//   Future<void> _loginCounter() async {
//     // Load and obtain the shared preferences for this app.
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _loggedUser = prefs.getString("user");
//       _counter = (prefs.getInt('counter_${_loggedUser?.toLowerCase()}') ?? 0) + 1;
//       prefs.setInt('counter_${_loggedUser?.toLowerCase()}', _counter);
//     });
//   }
//
//   Future<void> _resetCounter() async {
//     // Load and obtain the shared preferences for this app.
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _loggedUser = prefs.getString("user");
//       _counter = 0;
//       prefs.setInt('counter_${_loggedUser?.toLowerCase()}', _counter);
//     });
//   }
//
//
//   Future<void> fetchBeer(bool enabled) async {
//     var beerOptions = ["ale", "stouts"];
//     var beerType = beerOptions[Random().nextInt(2)];
//     var beerId = Random().nextInt(beerType == "ale" ? 181 : 118);
//     if(enabled == true) {
//       final response = await http
//           .get(Uri.parse("https://api.sampleapis.com/beers/$beerType"));
//       if (response.statusCode == 200) {
//         // If the server did return a 200 OK response,
//         List<dynamic> data = jsonDecode(response.body);
//
//         // Filter the element with id value equal to 3
//         var filteredElement = data.where((element) => element['id'] == beerId).toList();
//         // print(filteredElement);
//         setState(() {
//           filteredBeer = filteredElement.first as Map<String, dynamic>;
//           beerVisible = true;
//         });
//       } else {
//         // If the server did not return a 200 OK response,
//         // then throw an exception.
//         throw Exception('Failed to load image');
//       }
//     } else {
//       setState(() {
//         beerVisible = false;
//       });
//       //print("Turn off API connection");
//     }
//   }
//
//   static const chayanneFrases = [
//     "\"Fuiste tanto y fuiste tan poco, así son las historias de locos\"",
//     "\"Que si nos quedara poco tiempo, si mañana acaban nuestros días, \ny si no te he dicho suficiente, que te adoro con la vida\"",
//     "\"Y tú te vas así como si nada, acortándome la vida, agachando la mirada\"",
//     "\"De lunes a domingo voy desesperado, el corazón prendido allí en el calendario, \nbuscándote y buscando como un mercenario\"",
//     "\"Si hay que ser torero poner el alma en el ruedo, no importa lo que se venga \npa' que sepas que te quiero\"",
//     "\"pa' que sepas que te quiero, Como un buen torero (ole) me juego la vida por ti\"",
//     "\"Que yo quiero ser tu alma, ser tu socio, ser tu amante, ser tu amigo, la mitad de tu destino.\"",
//     "\"En palabras simples y comunes yo te extrañó, en lenguaje terrenal mi vida eres tú\"",
//     "\"No tires piedras al vecino si de cristal es tu tejado\"",
//     "\"Y, ¿qué me has hecho? que hasta perdí la razón\"",
//     "\"Para tu tranquilidad me tienes en tus masnos, para mi debilidad la única eres tú\"",
//     "\"Tú tienes el control de lo que pienso, de lo que imagino, \ntienes todo lo que quiero, lo que necesito.\""
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Container (
//             color: Colors.grey[200],
//             padding: const EdgeInsets.all(16.0),
//             child: RichText(
//               text: TextSpan(
//                 style: const TextStyle(fontSize: 16, color: Colors.black),
//                 children: <TextSpan>[
//                   const TextSpan(
//                     text: 'What’s up? ',
//                   ),
//                   TextSpan(
//                     text: _loggedUser,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Container (
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(right: 10.0),
//                   child: Text(
//                     'You have signed in: $_counter times',
//                     style: const TextStyle(fontSize: 12),
//                   ),
//                 ),
//                 OutlinedButton.icon(
//                   onPressed: _resetCounter,
//                   icon: const Icon(Icons.refresh,size: 14),
//                   label: const Text('Reset', style: TextStyle(fontSize: 12),),
//                 ),
//               ],
//             ),
//           ),
//           const FormSwitch(label: 'Git Server'),
//           const FormSwitch(label: 'CI/CD'),
//           const FormSwitch(label: 'Runners'),
//           const FormSwitch(label: 'Non-prod'),
//           FormSwitch(
//               label: 'Beer recommendation',
//               onChange: fetchBeer
//           ),
//           Visibility(
//             visible: beerVisible,
//             child: Container(
//               padding: const EdgeInsets.all(16.0),
//               color: Colors.grey[200],
//               child: filteredBeer == null
//                   ? const CircularProgressIndicator()
//                   : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Name: ${filteredBeer!['name']}\n'
//                         'Price: ${filteredBeer!['price']}\n',
//                     style: const TextStyle(fontSize: 18),
//                   ),
//                   Image.network(filteredBeer!['image']),
//                 ],
//               ),
//             ),
//           ),
//           FormSwitch(
//             label: "Chayanne's Wisdom Phrase",
//             onChange: (bool enabled){
//               if(enabled == true) {
//                 setState(() {
//                   phraseIndex = Random().nextInt(12);
//                 });
//               }
//               setState(() {
//                 phraseVisible = enabled;
//               });
//             },
//           ),
//           const SizedBox(height: 10),
//           Visibility(
//               visible: phraseVisible,
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(16.0),
//                     color: Colors.grey[200],
//                     child: Text(
//                       chayanneFrases[phraseIndex],
//                       style: const TextStyle(fontStyle: FontStyle.italic),
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   IconButton(
//                     iconSize: 32,
//                     icon: const Icon(Icons.restart_alt),
//                     onPressed: () {
//                       setState(() {
//                         phraseIndex = Random().nextInt(12);
//                       });
//                     },
//                   ),
//                 ],
//               )
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// Route _createRoute() {
//   return PageRouteBuilder(
//     pageBuilder: (context, animation, secondaryAnimation) => const Home(),
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       return child;
//     },
//   );
// }
//
//
// // Login Card widget.
// class LoginCard extends StatefulWidget {
//   const LoginCard({super.key});
//
//   @override
//   State<LoginCard> createState() => _LoginCardState();
// }
//
// class _LoginCardState extends State<LoginCard> {
//   final userNameController = TextEditingController();
//   final passController = TextEditingController();
//
//   bool loginError = false;
//
//   static const allowedUsers = [
//     "Isaac",
//     "Karen",
//     "Alfonso",
//     "Moneda"
//   ];
//
//   @override
//   void dispose() {
//     // Clean up the controller when the widget is disposed.
//     userNameController.dispose();
//     passController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _setUser(String user) async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       prefs.setString('user', user);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Card(
//         margin: const EdgeInsets.all(20.0),
//         color: Colors.black,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               TextField(
//                 controller: userNameController,
//                 style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
//                 decoration: const InputDecoration(
//                   labelText: 'Username',
//                   labelStyle: TextStyle(color: Colors.white),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextField(
//                 controller: passController,
//                 style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
//                 decoration: const InputDecoration(
//                   labelText: 'Password',
//                   labelStyle: TextStyle(color: Colors.white),
//                 ),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 20),
//               Visibility(
//                 visible: loginError,
//                 child: const Text(
//                   'Username or password wrong',
//                   style: TextStyle(color: Colors.red),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   if(allowedUsers.contains(userNameController.text) && passController.text == "ubiqus") {
//                     setState(() {
//                       loginError = false;
//                     });
//                     _setUser(userNameController.text);
//                     Navigator.of(context).push(_createRoute());
//                   } else {
//                     setState(() {
//                       loginError = true;
//                     });
//                   }
//                 },
//                 child: const Text('Login'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Switch element definition.
// class FormSwitch extends StatefulWidget {
//   final String label;
//   final Function(bool)? onChange;
//
//   const FormSwitch({super.key, required this.label, this.onChange});
//
//   @override
//   State<FormSwitch> createState() => _SwitchState();
// }
//
// class _SwitchState extends State<FormSwitch> {
//   bool enabled = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return SwitchListTile(
//       title: Text(widget.label),
//       // This bool value toggles the switch.
//       value: enabled,
//       activeColor: Colors.green,
//       onChanged: (bool value) {
//         // This is called when the user toggles the switch.
//         setState(() {
//           enabled = value;
//         });
//         if(widget.onChange != null) {
//           widget.onChange!(value);
//         }
//       },
//     );
//   }
// }
