class GameDetails {
  int id;
  int status;
  int position;
  int turn;
  String player1;
  String player2;
  List<dynamic> ships;
  List<dynamic> wrecks;
  List<dynamic> shots;
  List<dynamic> sunk;

  GameDetails({
    required this.id,
    required this.status,
    required this.position,
    required this.turn,
    required this.player1,
    required this.player2,
    required this.ships,
    required this.wrecks,
    required this.shots,
    required this.sunk,
  });
}
