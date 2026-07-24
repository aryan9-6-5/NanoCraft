import 'dart:convert';

class Puzzle {
  final String levelId;
  final List<List<bool>> grid; // 2D solution representation where true is filled, false is empty
  final List<List<int>> rowClues;
  final List<List<int>> columnClues;

  const Puzzle({
    required this.levelId,
    required this.grid,
    required this.rowClues,
    required this.columnClues,
  });

  Puzzle copyWith({
    String? levelId,
    List<List<bool>>? grid,
    List<List<int>>? rowClues,
    List<List<int>>? columnClues,
  }) {
    return Puzzle(
      levelId: levelId ?? this.levelId,
      grid: grid ?? this.grid,
      rowClues: rowClues ?? this.rowClues,
      columnClues: columnClues ?? this.columnClues,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'levelId': levelId,
      'grid': jsonEncode(grid),
      'rowClues': jsonEncode(rowClues),
      'columnClues': jsonEncode(columnClues),
    };
  }

  factory Puzzle.fromMap(Map<String, dynamic> map) {
    final gridRaw = jsonDecode(map['grid'] as String? ?? '[]') as List;
    final grid = gridRaw.map((row) => List<bool>.from(row as List)).toList();

    final rowCluesRaw = jsonDecode(map['rowClues'] as String? ?? '[]') as List;
    final rowClues = rowCluesRaw.map((row) => List<int>.from(row as List)).toList();

    final colCluesRaw = jsonDecode(map['columnClues'] as String? ?? '[]') as List;
    final colClues = colCluesRaw.map((row) => List<int>.from(row as List)).toList();

    return Puzzle(
      levelId: map['levelId'] as String? ?? '',
      grid: grid,
      rowClues: rowClues,
      columnClues: colClues,
    );
  }
}
