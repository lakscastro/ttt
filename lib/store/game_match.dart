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
}

class GameMatch {
  GameMatch({
    this.turnOf = Player.x,
    List<List<Player?>>? board,
    this.paused = false,
  }) : board = board ?? _generateEmptyBoard();

  static List<List<Player?>> _generateEmptyBoard() {
    return [
      _generateEmptyRow(),
      _generateEmptyRow(),
      _generateEmptyRow(),
    ];
  }

  static List<Player?> _generateEmptyRow() {
    return <Player?>[null, null, null];
  }

  List<List<Player?>> board;
  bool paused = false;
  Player turnOf;

  bool get _hasWinner => _computeWinner() != null;
  bool get isComplete =>
      _hasWinner || board.every((row) => row.every((cell) => cell != null));
  Player? get winner => isComplete ? _computeWinner() : null;
  bool get isDraw => isComplete && !_hasWinner;
  List<List<int>>? get winnerCells => _hasWinner ? _computeWinnerCells() : null;

  void pause() => paused = true;

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
    if (paused || player != turnOf || isComplete) return false;

    if (board[row][column] != null) {
      return false;
    }

    board[row][column] = player;
    turnOf = turnOf == Player.x ? Player.o : Player.x;

    return true;
  }
}
