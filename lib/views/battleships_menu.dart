// ignore_for_file: must_be_immutable

import 'package:battleships/views/completed_games.dart';
import 'package:battleships/views/games_page.dart';
import 'package:battleships/views/login_page.dart';
import 'package:flutter/material.dart';

import 'battleships_menu_display.dart';

class BattleshipsMenu extends StatefulWidget {
  String token;
  String username;
  BattleshipsMenu({super.key, required this.token, required this.username});

  @override
  State<BattleshipsMenu> createState() => _BattleshipsMenuState();
}

class _BattleshipsMenuState extends State<BattleshipsMenu> {
  @override
  void initState() {
    super.initState();
  }

  int _selectedIndex = 0;
  int _activeIndex = 0;

  void _changeSelection(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _changeActiveWindow(int index) {
    setState(() {
      _activeIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Battleships"),
            centerTitle: true,
            actions: [
              IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                            builder: (_) => BattleshipsMenu(
                                token: widget.token,
                                username: widget.username)),
                      )
                      .then((value) => setState(() {}))),
            ]),
        drawer: BattleshipsMenuDisplay(
          selected: _selectedIndex,
          changeSelection: _changeSelection,
          username: widget.username,
          token: widget.token,
          changeActiveWindow: _changeActiveWindow,
          activeWindow: _activeIndex,
        ),
        body: switch (_selectedIndex) {
          0 => switch (_activeIndex) {
              1 => CompletedGamesPage(
                  token: widget.token,
                  username: widget.username,
                ),
              0 => GamesPage(
                  token: widget.token,
                  username: widget.username,
                ),
              _ => throw UnimplementedError('no widget for $_selectedIndex')
            },
          3 => const LogoutNavigator(),
          _ => throw UnimplementedError('no widget for $_selectedIndex')
        });
  }
}

class LogoutNavigator extends StatelessWidget {
  const LogoutNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });

    return Container();
  }
}
