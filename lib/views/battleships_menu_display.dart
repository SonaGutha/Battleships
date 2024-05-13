import 'package:battleships/utils/session_manager.dart';
import 'package:battleships/views/new_game_screen.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BattleshipsMenuDisplay extends StatefulWidget {
  final int selected;
  final int activeWindow;
  String username;
  String token;
  bool isGameActive = false;
  final void Function(int index) changeSelection;
  final void Function(int index) changeActiveWindow;

  BattleshipsMenuDisplay(
      {required this.selected,
      required this.changeSelection,
      required this.username,
      required this.token,
      required this.changeActiveWindow,
      super.key,
      required this.activeWindow});

  @override
  State createState() => _BattleshipsMenuDisplayState();
}

class _BattleshipsMenuDisplayState extends State<BattleshipsMenuDisplay> {
  Future<void> _doLogout() async {
    await SessionManager.clearSession();
    if (!mounted) return;
  }

  void _showAIOptions() {
    showDialog(
      context: context,
      builder: (BuildContext builderContext) {
        return AlertDialog(
            title: const Text(
              'Which AI do you want to play against?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: const Text('Random',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16.0)),
                    onTap: () {
                      Navigator.pop(builderContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewGameScreen(
                                token: widget.token,
                                username: widget.username,
                                ai: 'random')),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Perfect',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16.0)),
                    onTap: () {
                      Navigator.pop(builderContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewGameScreen(
                                token: widget.token,
                                username: widget.username,
                                ai: 'perfect')),
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('One ship (A1)',
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16.0)),
                    onTap: () {
                      Navigator.pop(builderContext);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewGameScreen(
                                token: widget.token,
                                username: widget.username,
                                ai: 'oneship')),
                      );
                    },
                  ),
                ],
              ),
            ));
      },
    );
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                children: [
                  Expanded(
                      child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "Battleships",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                  )),
                  Expanded(
                      child: Container(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Logged in as ${widget.username}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                    ),
                  )),
                ],
              ),
            ),
            GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewGameScreen(
                            token: widget.token,
                            username: widget.username,
                            ai: '')),
                  );
                },
                child: ListTile(
                  leading: const Icon(Icons.add, color: Colors.grey),
                  title: const Text("New game"),
                  selected: widget.selected == 1,
                )),
            GestureDetector(
              onTap: () {
                _showAIOptions();
              },
              child: ListTile(
                leading:
                    const Icon(Icons.tap_and_play_rounded, color: Colors.grey),
                title: const Text("New game (AI)"),
                selected: widget.selected == 2,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.list, color: Colors.grey),
              title: widget.activeWindow == 0
                  ? const Text("Show completed games")
                  : const Text("Show active games"),
              selected: widget.selected == 0,
              onTap: widget.activeWindow == 0
                  ? () {
                      widget.changeActiveWindow(1);
                      Navigator.pop(context);
                    }
                  : () {
                      widget.changeActiveWindow(0);
                      Navigator.pop(context);
                    },
            ),
            GestureDetector(
                onTap: () {
                  _doLogout();
                  widget.changeSelection(3);
                  Navigator.pop(context);
                },
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.grey),
                  title: const Text("Log out"),
                  selected: widget.selected == 3,
                ))
          ],
        ),
      ),
    );
  }
}
