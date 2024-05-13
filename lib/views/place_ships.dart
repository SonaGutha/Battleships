import 'package:battleships/utils/session_manager.dart';
import 'package:battleships/views/battleships_menu.dart';
import 'package:battleships/views/login_page.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

// ignore: must_be_immutable
class PlaceShipsPage extends StatefulWidget {
  final String token;
  final String username;
  String ai;
  PlaceShipsPage(
      {super.key,
      required this.token,
      required this.username,
      required this.ai});
  @override
  State<PlaceShipsPage> createState() => _PlaceShipsPageState();
}

class _PlaceShipsPageState extends State<PlaceShipsPage> {
  Set<int> selectedCells = {};
  List<String> battleships = [];
  int? hoveredCell;

  Future<void> _doLogout() async {
    await SessionManager.clearSession();
    if (!mounted) return;
  }

  Future<void> _postGame(BuildContext context) async {
    final url = Uri.parse('http://165.227.117.48/games');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': widget.token,
        },
        body: jsonEncode(
            {'ships': battleships, 'ai': widget.ai != "" ? widget.ai : ''}));

    if (!mounted) return;

    if (response.statusCode == 200) {
      if (!mounted) return;

      Navigator.of(context)
          .push(
            MaterialPageRoute(
                builder: (_) => BattleshipsMenu(
                    token: widget.token, username: widget.username)),
          )
          .then((value) => setState(() {}));
    } else if (response.statusCode == 401) {
      _doLogout();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token Expired. Please login again'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(
              height: 10,
            ),
            for (var rowName in ['A', 'B', 'C', 'D', 'E'])
              Expanded(
                child: Center(
                  child: Text(
                    rowName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final aspectRatio = constraints.maxWidth / constraints.maxHeight;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      for (var colName in ['1', '2', '3', '4', '5'])
                        Expanded(
                          child: Center(
                            child: Text(
                              colName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: gridtoplacebattleships(aspectRatio),
                    ),
                  ),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedCells.length < 5) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('You must place five ships'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } else {
                          _postGame(context);
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    ));
  }

  GridView gridtoplacebattleships(double aspectRatio) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: aspectRatio,
      ),
      itemCount: 25,
      itemBuilder: (context, index) {
        int row = index ~/ 5 + 1;
        int col = index % 5 + 1;
        String cellName =
            String.fromCharCode('A'.codeUnitAt(0) + row - 1) + col.toString();

        return GestureDetector(
          onTap: () {
            setState(() {
              if (selectedCells.contains(index)) {
                selectedCells.remove(index);
                battleships.remove(cellName);
              } else if (selectedCells.length < 5) {
                selectedCells.add(index);
                battleships.add(cellName);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You can only select up to 5 cells.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            });
          },
          child: MouseRegion(
            onEnter: (_) {
              setState(() {
                hoveredCell = index;
              });
            },
            onExit: (_) {
              setState(() {
                hoveredCell = null;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: selectedCells.contains(index)
                    ? Colors.blue[300]
                    : (hoveredCell == index)
                        ? Colors.green[100]
                        : Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}
