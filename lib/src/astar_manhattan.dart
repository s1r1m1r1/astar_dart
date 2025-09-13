import 'dart:math';

import 'package:astar_dart/astar_dart.dart';

class AStarManhattan extends AstarGrid {
  AStarManhattan({
    required super.rows,
    required super.columns,
    super.gridBuilder,
  });

  /// return full path without Start position
  /// for Point(0,0) to Point(0,3) result will be [Point(0,3),Point(0,2),Point(0,1)]
  /// ```dart
  /// final result = _astar.findPath(start: Point(0,0),end: Point(0,3));
  /// final moveTo = result.removeLast();
  /// final moveNext = result.removeLast();
  /// ```
  @override
  List<ANode> findPath({
    void Function(List<Point<int>>)? visited,
    required ({int x, int y}) start,
    required ({int x, int y}) end,
  }) {
    if (grid[end.x][end.y].isBarrier) {
      return [];
    }

    ANode startNode = grid[start.x][start.y];

    ANode endNode = grid[end.x][end.y];
    if (_isNeighbors(start, end)) {
      return [];
    }

    ANode? winner = getWinner(
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
    // visited?.call(doneList.map((e) => Point(e.x, e.y)).toList());
    // doneList.clear();
    waitList.clear();

    if (winner == null && !_isNeighbors(start, end)) {
      path.clear();
    }

    return path.toList();
  }

//----------------------------------------------------------------------

  @override
  void analyzeDistance(ANode current, ANode end, {required ANode parent}) {
    current.parent = parent;
    current.g = parent.g + current.weight;

    /// performance , make direction more stronger
    current.h = _distance(current, end) * 2.0;
  }

  int _distance(ANode a, ANode b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs();
  }

  bool _isNeighbors(
    ({int x, int y}) start,
    ({int x, int y}) end,
  ) {
    int dx = (start.x - end.x).abs();
    int dy = (start.y - end.y).abs();

    // Manhattan
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
  }

  /// expensive not call every time,try reusing
  @override
  void addNeighbors() {
    final maxX = grid.length - 1;
    final maxY = grid.first.length - 1;
    for (var x = 0; x < grid.length; x++) {
      final row = grid[x];
      for (var y = 0; y < row.length; y++) {
        final node = row[y];
        node.reset();
        node.neighbors.clear();
        _chainNeighborsManhattan(node, maxX: maxX, maxY: maxY);
      }
    }
  }

  void _chainNeighborsManhattan(ANode node,
      {required int maxX, required int maxY}) {
    final x = node.x;
    final y = node.y;
    // Optimized neighbor adding for Manhattan distance (only cardinal directions)
    if (y > 0) {
      // Top
      final n = grid[x][y - 1];
      if (!n.isBarrier) {
        node.neighbors.add(n);
      }
    }
    if (y < maxY) {
      // Bottom
      final n = grid[x][y + 1];
      if (!n.isBarrier) {
        node.neighbors.add(n);
      }
    }
    if (x > 0) {
      // Left
      final n = grid[x - 1][y];
      if (!n.isBarrier) {
        node.neighbors.add(n);
      }
    }
    if (x < maxX) {
      // Right
      final n = grid[x + 1][y];
      if (!n.isBarrier) {
        node.neighbors.add(n);
      }
    }
  }
}
