import 'dart:async';
import 'dart:math';

import '../astar_dart.dart';

class AStarEuclidean extends AstarGrid {
  final List<ANode> _doneList = [];
  final List<ANode> _waitList = [];

  AStarEuclidean({
    required int rows,
    required int columns,
    required GridBuilder gridBuilder,
  }) : super(
          rows: rows,
          columns: columns,
          gridBuilder: gridBuilder
        );

  /// return full path without Start position
  /// for Point(0,0) to Point(0,3) result will be [Point(0,3),Point(0,2),Point(0,1)]
  /// ```dart
  /// final result = _astar.findPath(start: Point(0,0),end: Point(0,3));
  /// final moveTo = result.removeLast();
  /// final moveNext = result.removeLast();
  /// ```
  @override
  FutureOr<List<ANode>> findPath({
    void Function(List<Point<int>>)? doneList,
    required Point<int> start,
    required Point<int> end,
  }) {
    super.start = start;
    super.end = end;
    _doneList.clear();
    _waitList.clear();

    if (grid[end.x][end.y].barrier.isBlock) {
      return Future.value([]);
    }

    ANode startNode = grid[start.x][start.y];

    ANode endNode = grid[end.x][end.y];
    if (_isNeighbors(start, end)) {
      return [];
    }

    ANode? winner = _getWinner(
      startNode,
      endNode,
    );

    List<ANode> path = [grid[end.x][end.y]];
    if (winner?.parent != null) {
      ANode nodeAux = winner!.parent!;
      for (int i = 0; i < winner.g - 1; i++) {
        if (nodeAux == startNode) {
          break;
        }
        path.add(nodeAux);
        nodeAux = nodeAux.parent!;
      }
    }
    doneList?.call(_doneList.map((e) => Point(e.x, e.y)).toList());

    if (winner == null && !_isNeighbors(start, end)) {
      path.clear();
    }

    return Future.value(path.toList());
  }

  ANode? _getWinner(ANode current, ANode end) {
    ANode? winner;
    if (end == current) return current;
    for (var n in current.neighbors) {
      if (n.parent == null) {
        _checkDistance(n, end, parent: current);
      }
      if (!_doneList.contains(n)) {
        _waitList.add(n);
      }
    }

    while (_waitList.isNotEmpty) {
      final c = _waitList.removeLast();
      if (end == c) return c;
      for (var n in c.neighbors) {
        if (n.parent == null) {
          _checkDistance(n, end, parent: c);
        }
        if (!_doneList.contains(n)) {
          _waitList.add(n);
        }
      }
      _doneList.add(c);
      _waitList.sort((a, b) => b.compareTo(a));
    }

    return winner;
  }

  void _checkDistance(ANode current, ANode end, {required ANode parent}) {
    current.parent = parent;
    current.g = parent.g + current.weight;
    current.h = _distance(current, end);
  }

  static const lineConst = 1.0; // Straight move cost
  static const diagonalConst =
      1.414; // Diagonal move cost (sqrt(2) for an even grid)

  double _distance(ANode current, ANode target) {
    int dx = (current.x - target.x).abs();
    int dy = (current.y - target.y).abs();
    return lineConst * (dx + dy) +
        (diagonalConst - 2 * lineConst) * min(dx, dy);
  }

  /// Calculates the distance between two nodes.
  // double _distance(ANode current, ANode target) {
  //   int toX = current.x - target.x;
  //   int toY = current.y - target.y;

  //   return sqrt(toX * toX + toY * toY); // Standard Euclidean distance
  // }

  bool _isNeighbors(Point<int> start, Point<int> end) {
    int dx = (start.x - end.x).abs();
    int dy = (start.y - end.y).abs();

    return dx <= 1 && dy <= 1;
  }

  /// Adds neighbors to cells
  @override
  void addNeighbors() {
    for (var row in grid.array) {
      for (ANode node in row) {
        node.parent = null;
        node.g = 0.0;
        node.h = 0.0;
        node.neighbors.clear();
        _chainNeighbors(node);
      }
    }
  }

  void _chainNeighbors(ANode node) {
    final x = node.x;
    final y = node.y;
    final maxX = grid.length - 1; // Cache max values for efficiency
    final maxY = grid.first.length - 1;

    // Optimized neighbor adding (combined conditions, removed redundant checks)
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        if (i == 0 && j == 0) continue; // Skip the current node itself

        final nx = x + i;
        final ny = y + j;

        if (nx >= 0 && nx <= maxX && ny >= 0 && ny <= maxY) {
          // Check bounds once
          final neighbor = grid[nx][ny];
          if (!grid[nx][ny].barrier.isBlock) {
            node.neighbors.add(neighbor);
          }
        }
      }
    }
  }
}
