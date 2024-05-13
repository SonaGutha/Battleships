class Game {
  int id;
  String player1;
  String player2;
  int position;
  int status;
  int turn;

  Game(
      {required this.id,
      required this.player1,
      required this.player2,
      required this.position,
      required this.status,
      required this.turn});
}
