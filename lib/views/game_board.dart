import 'package:battleships/models/game_details.dart';
import 'package:battleships/models/shot.dart';
import 'package:battleships/utils/session_manager.dart';
import 'package:battleships/views/battleships_menu.dart';
import 'package:battleships/views/login_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class GameBoardPage extends StatefulWidget {
  final Function(int, int)? onTap;
  final String token;
  final String username;
  final GameDetails gameDetails;
  String shot = '';
  bool isOpponentTurn;
  bool isMyTurn;
  bool isGameCompleted;
  bool isGameCompletionPage;
  final String baseUrl = 'http://165.227.117.48/games';
  GameBoardPage(
      {this.onTap,
      super.key,
      required this.token,
      required this.gameDetails,
      required this.username,
      required this.isOpponentTurn,
      required this.isMyTurn,
      required this.isGameCompleted,
      required this.isGameCompletionPage});
  @override
  State<GameBoardPage> createState() => _GameBoardPageState();
}

class _GameBoardPageState extends State<GameBoardPage> {
  Set<int> selectedCells = {};
  List<String> battleships = [];

  int? hoveredCell;
  bool isSubmitted = false;
  Shot placeshot = Shot();
  GameDetails? gameRefreshDetails;

  @override
  Widget build(BuildContext context) {
    Future<void> doLogout() async {
      await SessionManager.clearSession();
      if (!mounted) return;
    }

    Future<void> placeShot(BuildContext context, int id, String shot) async {
      final response = await http.put(Uri.parse('${widget.baseUrl}/$id'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': widget.token
          },
          body: jsonEncode({'shot': shot}));

      if (!mounted) return;
      Map<String, dynamic> data = json.decode(response.body);
      if (response.statusCode == 200) {
        placeshot.message = data['message'];
        placeshot.sunkship = data['sunk_ship'];
        placeshot.won = data['won'];
        if (!mounted) return;

        if (placeshot.sunkship) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sunk ship!'),
              duration: Duration(seconds: 2),
            ),
          );
          if (placeshot.won) {
            isSubmitted = true;
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Game Over'),
                  content: const Text('You won!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No enemy ship hit'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        isSubmitted = true;
      } else if (response.statusCode == 401) {
        doLogout();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Token Expired. Please login again'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ));
      } else if (response.statusCode == 400) {
        if (data['error'] == "Shot already played") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Shot already played'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }

    String buildGridCell(String value) {
      if (widget.gameDetails.ships.isNotEmpty) {
        for (var ship in widget.gameDetails.ships) {
          for (var wreck in widget.gameDetails.wrecks) {
            if (wreck == value) {
              return ('🫧');
            }
          }
          if (ship == value) {
            return ('🚢');
          }
        }
      } else {
        for (var wreck in widget.gameDetails.wrecks) {
          if (wreck == value) {
            return ('🫧');
          }
        }
      }
      return '';
    }

    String buildshotshunkCell(String value) {
      for (var shot in widget.gameDetails.shots) {
        for (var sunk in widget.gameDetails.sunk) {
          if (sunk == value) {
            return ('💥');
          }
        }
        if (shot == value) {
          return ('💣');
        }
      }
      return '';
    }

    String shotCell(String value) {
      for (var ship in widget.gameDetails.shots) {
        if (ship == value) {
          return ('💣');
        }
      }

      return "";
    }

    String shotPlaced(String value) {
      if (value == widget.shot) {
        if (placeshot.sunkship) {
          return ('💥');
        } else {
          return ('💣');
        }
      }
      return "";
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Play Game'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              widget.isGameCompletionPage
                  ? Navigator.of(context).pop()
                  : Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                            builder: (_) => BattleshipsMenu(
                                token: widget.token,
                                username: widget.username)),
                      )
                      .then((value) => setState(() {}));
            },
          ),
        ),
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
                  final aspectRatio =
                      constraints.maxWidth / constraints.maxHeight;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          // Adjust spacing
                          for (var colName in ['1', '2', '3', '4', '5'])
                            Expanded(
                              child: Center(
                                child: Text(
                                  colName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: gridtoplaygame(aspectRatio, buildGridCell,
                              shotPlaced, shotCell, buildshotshunkCell),
                        ),
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: (isSubmitted ||
                                  widget.isGameCompleted ||
                                  (widget.isOpponentTurn && !widget.isMyTurn))
                              ? null
                              : () {
                                  if (selectedCells.length == 1) {
                                    placeShot(context, widget.gameDetails.id,
                                        widget.shot);
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

  GridView gridtoplaygame(
      double aspectRatio,
      String Function(String value) buildGridCell,
      String Function(String value) shotPlaced,
      String Function(String value) shotCell,
      String Function(String value) buildshotshunkCell) {
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
              } else {
                selectedCells.clear();
                selectedCells.add(index);
                widget.shot = cellName;
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
              decoration: (isSubmitted ||
                      widget.isGameCompleted ||
                      (widget.isOpponentTurn && !widget.isMyTurn))
                  ? BoxDecoration(
                      color: selectedCells.contains(index)
                          ? Colors.white
                          : (hoveredCell == index)
                              ? Colors.green[100]
                              : Colors.white,
                    )
                  : BoxDecoration(
                      color: selectedCells.contains(index)
                          ? Colors.red[300]
                          : (hoveredCell == index)
                              ? Colors.green[100]
                              : Colors.white,
                    ),
              child: isSubmitted
                  ? Center(
                      child: Text(
                          '${buildGridCell(cellName)} ${buildshotshunkCell(cellName)} ${shotPlaced(cellName)}'),
                    )
                  : Center(
                      child: Text(
                        '${buildGridCell(cellName)} ${buildshotshunkCell(cellName)}  ',
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
