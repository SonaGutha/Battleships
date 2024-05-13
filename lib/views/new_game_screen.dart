// ignore_for_file: must_be_immutable

import 'package:battleships/views/place_ships.dart';
import 'package:flutter/material.dart';

class NewGameScreen extends StatefulWidget {
  final String token;
  final String username;
  String ai;
  NewGameScreen(
      {super.key,
      required this.token,
      required this.username,
      required this.ai});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place ships'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            if (widget.ai != "") {
              Navigator.of(context).pop();
            }
            Navigator.of(context).pop();
          },
        ),
      ),
      body: PlaceShipsPage(
          token: widget.token, username: widget.username, ai: widget.ai),
    );
  }
}
