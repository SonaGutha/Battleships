import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/session_manager.dart';

import 'battleships_menu.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoggedIn = false;
  late String token;
  late String username;

  @override
  void initState() {
    super.initState();
    token = "";
    username = "";
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await SessionManager.isLoggedIn();
    if (mounted) {
      setState(() {
        isLoggedIn = loggedIn;
      });
    }
    if (isLoggedIn) {
      _getTokenIfAlreadyLoggedin();
    }
  }

  void _getTokenIfAlreadyLoggedin() async {
    Future<String> sessionToken = SessionManager.getSessionToken();
    Future<String> sessionUserName = SessionManager.getUserName();
    String sessionTokenStr = await sessionToken;
    String sessionUserNameStr = await sessionUserName;

    token = 'Bearer $sessionTokenStr';
    username = sessionUserNameStr;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      home: isLoggedIn
          ? BattleshipsMenu(
              token: token,
              username: username,
            )
          : LoginScreen(
              token: token,
              username: username,
            ),
    );
  }
}

// ignore: must_be_immutable
class LoginScreen extends StatefulWidget {
  String token;
  String username;
  LoginScreen({super.key, required this.token, required this.username});

  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _getToken() async {
    Future<String> sessionToken = SessionManager.getSessionToken();
    Future<String> sessionUserName = SessionManager.getUserName();
    String sessionTokenStr = await sessionToken;
    String sessionUserNameStr = await sessionUserName;
    widget.token = 'Bearer $sessionTokenStr';
    widget.username = sessionUserNameStr;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => _login(context),
                  child: const Text('Log in'),
                ),
                TextButton(
                  onPressed: () => _register(context),
                  child: const Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    final username = usernameController.text;
    final password = passwordController.text;

    final url = Uri.parse('http://165.227.117.48/login');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }));

    if (!mounted) return;

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);

      final sessionToken = data['access_token'];
      await SessionManager.setSessionToken(sessionToken, username);

      _getToken();

      if (!mounted) return;

      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BattleshipsMenu(
          token: widget.token,
          username: widget.username,
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _register(BuildContext context) async {
    final username = usernameController.text;
    final password = passwordController.text;

    final url = Uri.parse('http://165.227.117.48/register');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }));

    if (!mounted) return;

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      final sessionToken = data['access_token'];
      await SessionManager.setSessionToken(sessionToken, username);
      if (!mounted) return;

      _getToken();

      // go to the main screen
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => BattleshipsMenu(
          token: widget.token,
          username: widget.username,
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration failed'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
