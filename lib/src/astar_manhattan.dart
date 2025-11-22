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
    required Point<int> start,
    required Point<int> end,
  }) {
    if (grid[end.x][end.y].isBarrier) {
      return [];
    }

    ANode aStart = grid[start.x][start.y];

    ANode aEnd = grid[end.x][end.y];
    if (aEnd.isBarrier) return [aStart];
    if (_isNeighbors(start, end)) return [aEnd, aStart];

    aStart.g = 0;
    aStart.visited = true;

    ANode? winner = getWinner(
      aStart,
      aEnd,
    );
    if (winner == null) return [aStart];
    final path = reconstruct(winner);
    visited?.call(grid.whereabout((i) => i.visited).toList());
    return path;
  }

//----------------------------------------------------------------------

  @override
  void analyzeDistance(ANode current, ANode end, {required ANode parent}) {
    current.parent = parent;
    current.g = parent.g + current.weight;

    /// performance , make direction more stronger
    current.h = _distance(current, end) * 2;
  }

  int _distance(ANode a, ANode b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs();
  }

  bool _isNeighbors(
    Point<int> start,
    Point<int> end,
  ) {
    int dx = (start.x - end.x).abs();
    int dy = (start.y - end.y).abs();

    // Manhattan
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
  }

  /// expensive not call every time,try reusing
  @override
  void addNeighbors() {
    final maxX = grid.width - 1;
    final maxY = grid.height - 1;
    grid.forEach((node, x, y) {
      node.reset();
      node.neighbors.clear();
      if (node.isBarrier) return;
      _chainNeighborsManhattan(node, maxX: maxX, maxY: maxY);
    });
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
