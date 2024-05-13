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

class CompletedGamesPage extends StatefulWidget {
  String token;
  String username;
  final String baseUrl = 'http://165.227.117.48/games';

  CompletedGamesPage({super.key, required this.token, required this.username});

  @override
  State createState() => _CompletedGamesPageState();
}

class _CompletedGamesPageState extends State<CompletedGamesPage> {
  Future<Games>? futurePosts;
  bool isGameCompleted = false;
  bool isGameCompletionPage = true;

  @override
  void initState() {
    super.initState();
    futurePosts = _loadPosts();
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
      setState(() {});
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => GameBoardPage(
            token: widget.token,
            gameDetails: gameDetails,
            username: widget.username,
            isOpponentTurn: false,
            isMyTurn: false,
            isGameCompleted: isGameCompleted,
            isGameCompletionPage: isGameCompletionPage),
      ));
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

  Future<void> refreshPosts() async {
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
                  if (post.turn == 0) {
                    isGameCompleted = true;
                    if (post.status == 1 && post.player1 == widget.username ||
                        post.status == 2 && post.player2 == widget.username) {
                      return gameWonLogic(post, context);
                    } else if (post.status == 1 &&
                            post.player2 == widget.username ||
                        post.status == 2 && post.player1 == widget.username) {
                      return gameLostLogic(post, context);
                    } else {
                      return Container();
                    }
                  } else {
                    return Container();
                  }
                });
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

  GestureDetector gameLostLogic(Game post, BuildContext context) {
    return GestureDetector(
      onTap: () {
        ListTile(
          title: Text(
              '#${post.id.toString()} ${post.player1} vs ${post.player2}',
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0)),
          trailing: const Text('gameLost',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.0)),
        );
        _getGame(context, post.id);
      },
      child: Container(
        child: ListTile(
          title: Text(
              '#${post.id.toString()} ${post.player1} vs ${post.player2}',
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0)),
          trailing: const Text('gameLost',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.0)),
        ),
      ),
    );
  }

  GestureDetector gameWonLogic(Game post, BuildContext context) {
    return GestureDetector(
      onTap: () {
        ListTile(
          title: Text(
              '#${post.id.toString()} ${post.player1} vs ${post.player2}',
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0)),
          trailing: const Text('gameWon',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.0)),
        );
        _getGame(context, post.id);
      },
      child: ListTile(
        title: Text('#${post.id.toString()} ${post.player1} vs ${post.player2}',
            style:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 16.0)),
        trailing: const Text('gameWon',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13.0)),
      ),
    );
  }
}
