import 'package:flutter/material.dart';
import '../services/login_service.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({super.key});

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final userNameController = TextEditingController();
  final passController = TextEditingController();
  final LoginService _loginService = LoginService(); // Instantiate the LoginService

  bool loginError = false;

  @override
  void dispose() {
    userNameController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _checkTokenAndRedirect();
  }

  Future<void> _checkTokenAndRedirect() async {
    String? token = await _loginService.checkToken();
    if (token != null) {
      // Navigate to home page if a valid token exists
      Navigator.of(context, rootNavigator: true).pushNamed("/home");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20.0),
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: userNameController,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                decoration: const InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passController,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              Visibility(
                visible: loginError,
                child: const Text(
                  'Username or password wrong',
                  style: TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (await _loginService.isValidUser(userNameController.text, passController.text)) {
                    setState(() {
                      loginError = false;
                    });
                    _loginService.setUser(userNameController.text);
                    Navigator.of(context, rootNavigator: true).pushNamed("/home");
                  } else {
                    setState(() {
                      loginError = true;
                    });
                  }
                },
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
