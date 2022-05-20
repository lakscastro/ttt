import 'dart:convert';

import '../const/game.dart';

enum Player { x, o }

Player? parsePlayer(String name) {
  for (final value in Player.values) {
    if (value.name == name) {
      return value;
    }
  }

  return null;
}

extension PlayerExtension on Player {
  bool same(Player other) => this == other;
  Player opposite() => this == Player.x ? Player.o : Player.x;
}

/// Represents a game match, to restart it, just create a new instance of this class
///
/// This class contains all game logic, if some player can move, which one has the turn, etc.
class GameMatch {
  GameMatch({this.turnOf = Player.x, List<List<Player?>>? board})
      : board = board ?? _generateEmptyBoard();

  // We can't use `static const` because it implies
  // that all matches uses the same List instance.
  //
  // To notice that, it costs 2 hours of my life
  static List<List<Player?>> _generateEmptyBoard() {
    return [
      for (var i = 0; i < 3; i++) _generateEmptyRow(),
    ];
  }

  static List<Player?> _generateEmptyRow() {
    return <Player?>[for (var j = 0; j < 3; j++) null];
  }

  List<List<Player?>> board;
  Player turnOf;

  bool get hasWinner => _computeWinner() != null;
  bool get isComplete =>
      hasWinner || board.every((row) => row.every((cell) => cell != null));
  Player? get winner => isComplete ? _computeWinner() : null;
  bool get isDraw => isComplete && !hasWinner;
  List<List<int>>? get winnerCells => hasWinner ? _computeWinnerCells() : null;

  Player? _computeWinner() {
    final match = _computeWinnerCells();

    if (match != null) {
      return board[match.first[0]][match.first[1]];
    }

    return null;
  }

  List<List<int>>? _computeWinnerCells() {
    for (final solution in kSolutions) {
      final winner = {
        for (final position in solution) board[position[0]][position[1]]
      };

      if (winner.first != null && winner.length == 1) {
        return solution;
      }
    }

    return null;
  }

  bool play(int row, int column, {required Player player}) {
    if (player != turnOf || isComplete) return false;

    if (board[row][column] != null) {
      return false;
    }

    board[row][column] = player;
    turnOf = turnOf.opposite();

    return true;
  }
}

/// Use it to encode data to send over sockets
String encodeGameState(GameMatch match) {
  final a = match.board
      .map<List<String?>>((e) => e.map<String?>((e) => e?.name).toList())
      .toList();
  return jsonEncode(
    <String, dynamic>{
      'board': a,
      'turnOf': match.turnOf.name,
    },
  );
}

/// Use it to decode data to received over sockets
GameMatch decodeGameState(String match) {
  final map = jsonDecode(match) as Map<String, dynamic>;

  return GameMatch(
    board: (map['board'] as List<dynamic>)
        .map(
          (e) => (e as List)
              .map<Player?>((e) => e == null ? null : parsePlayer(e as String))
              .toList(),
        )
        .cast<List<Player?>>()
        .toList(),
    turnOf: parsePlayer(map['turnOf'] as String)!,
  );
}
