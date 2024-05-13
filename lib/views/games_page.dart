// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'package:battleships/models/game.dart';
import 'package:battleships/models/game_details.dart';
import 'package:battleships/models/games.dart';
import 'package:battleships/utils/session_manager.dart';
import 'package:battleships/views/game_board.dart';
import 'package:battleships/views/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GamesPage extends StatefulWidget {
  String token;
  String username;
  final String baseUrl = 'http://165.227.117.48/games';

  GamesPage({super.key, required this.token, required this.username});

  @override
  State createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  Future<Games>? futurePosts;

  bool isOpponenturn = false;
  bool isMyTurn = false;

  @override
  void initState() {
    super.initState();
    futurePosts = _loadPosts();
  }

  Future<void> _deletePost(int id) async {
    final response = await http.delete(
      Uri.parse('${widget.baseUrl}/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': widget.token
      },
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Game forfeited'),
          duration: Duration(seconds: 2),
        ),
      );
      _refreshPosts();
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

  Future<void> _getGame(BuildContext context, int id) async {
    final response = await http.get(Uri.parse('${widget.baseUrl}/$id'),
        headers: {'Authorization': widget.token});

    if (!mounted) return;

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      GameDetails gameDetails = GameDetails(
          id: data['id'],
          status: data['status'],
          position: data['position'],
          turn: data['turn'],
          player1: data['player1'],
          player2: data['player2'] ?? "",
          ships: data['ships'],
          wrecks: data['wrecks'],
          shots: data['shots'],
          sunk: data['sunk']);

      if (!mounted) return;

      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => GameBoardPage(
          token: widget.token,
          gameDetails: gameDetails,
          username: widget.username,
          isOpponentTurn: isOpponenturn,
          isMyTurn: isMyTurn,
          isGameCompleted: false,
          isGameCompletionPage: false,
        ),
      ));

      setState(() {});
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

  Future<void> _refreshPosts() async {
    setState(() {
      futurePosts = _loadPosts();
    });
  }

  Future<void> _doLogout() async {
    await SessionManager.clearSession();
    if (!mounted) return;
  }

  Future<Games> _loadPosts() async {
    final response = await http.get(Uri.parse(widget.baseUrl),
        headers: {'Authorization': widget.token});
    final posts = json.decode(response.body);
    Games games = Games();
    if (response.statusCode == 200) {
      for (var post in posts['games']) {
        Game game = Game(
            id: post['id'],
            player1: post['player1'],
            player2: post['player2'] ?? "",
            position: post['position'],
            status: post['status'],
            turn: post['turn']);
        games.games.add(game);
      }
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
    return games;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Games>(
        future: futurePosts,
        initialData: null,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.games.length,
              itemBuilder: (context, index) {
                final post = snapshot.data!.games[index];

                if (post.status == 0) {
                  return matchmakinglogic(post, context, snapshot, index);
                } else if (post.status == 3 &&
                        post.position == 1 &&
                        post.turn == 1 ||
                    post.status == 3 && post.position == 2 && post.turn == 2) {
                  return myturnlogic(post, context, snapshot, index);
                } else if (post.status == 3 &&
                        post.position == 1 &&
                        post.turn == 2 ||
                    post.status == 3 && post.position == 2 && post.turn == 1) {
                  return opponentturnlogic(post, context, snapshot, index);
                } else {
                  return Container();
                }
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  GestureDetector opponentturnlogic(Game post, BuildContext context,
      AsyncSnapshot<Games> snapshot, int index) {
    return GestureDetector(
        onTap: () {
          ListTile(
            title: Text(
                '#${post.id.toString()} ${post.player1} vs ${post.player2}',
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 16.0)),
            trailing: const Text("opponentTurn",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.0)),
          );
          isOpponenturn = true;
          _getGame(context, post.id);
        },
        child: Dismissible(
          key: Key(post.id.toString()),
          onDismissed: (_) {
            snapshot.data!.games.removeAt(index);
            _deletePost(post.id);
          },
          background: Container(
            color: Colors.red,
            child: const Icon(Icons.delete),
          ),
          child: ListTile(
            title: Text(
                '#${post.id.toString()} ${post.player1} vs ${post.player2}',
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 16.0)),
            trailing: const Text("opponnetTurn",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.0)),
          ),
        ));
  }

  GestureDetector myturnlogic(Game post, BuildContext context,
      AsyncSnapshot<Games> snapshot, int index) {
    return GestureDetector(
        onTap: () {
          ListTile(
            title: Text(
              '#${post.id.toString()} ${post.player1} vs ${post.player2}',
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0),
            ),
            trailing: const Text("myTurn",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.0)),
          );
          isMyTurn = true;
          _getGame(context, post.id);
        },
        child: Dismissible(
          key: Key(post.id.toString()),
          onDismissed: (_) {
            snapshot.data!.games.removeAt(index);
            _deletePost(post.id);
          },
          background: Container(
            color: Colors.red,
            child: const Icon(Icons.delete),
          ),
          child: ListTile(
            title: Text(
              '#${post.id.toString()} ${post.player1} vs ${post.player2}',
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0),
            ),
            trailing: const Text("myTurn",
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.0)),
          ),
        ));
  }

  GestureDetector matchmakinglogic(Game post, BuildContext context,
      AsyncSnapshot<Games> snapshot, int index) {
    return GestureDetector(
      onTap: () {
        ListTile(
          title: Text('#${post.id.toString()} Waiting for opponent',
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0)),
          trailing: const Text('matchmaking',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.0)),
        );
        isMyTurn = true;
        _getGame(context, post.id);
      },
      child: Dismissible(
        key: Key(post.id.toString()),
        onDismissed: (_) {
          snapshot.data!.games.removeAt(index);
          _deletePost(post.id);
        },
        background: Container(
          color: Colors.red,
          child: const Icon(Icons.delete),
        ),
        child: ListTile(
          title: Text('#${post.id.toString()} Waiting for opponent',
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0)),
          trailing: const Text('matchmaking',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.0)),
        ),
      ),
    );
  }
}
