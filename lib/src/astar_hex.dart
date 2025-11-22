import 'dart:math';

import 'package:astar_dart/astar_dart.dart';

class AStarHex extends AstarGrid {
  AStarHex({
    required super.rows,
    required super.columns,
    required GridBuilder super.gridBuilder,
  });

  @override
  List<ANode> findPath({
    void Function(List<Point<int>>)? visited,
    required Point<int> start,
    required Point<int> end,
  }) {
    /// If the end node is blocked, return an empty path.

    /// Get the start and end nodes from the grid.
    ANode startNode = grid[start.x][start.y];
    ANode endNode = grid[end.x][end.y];

    /// If start and end are neighbors, return a direct path.
    if (_isNeighbors(start, end)) return [endNode, startNode];
    if (endNode.isBarrier) return [startNode];

    startNode.g = 0;
    startNode.visited = true;
    ANode? winner = getWinner(startNode, endNode);
    if (winner == null) return [startNode];
    final path = reconstruct(winner);
    visited?.call(grid.whereabout((i) => i.visited).toList());
    return path;
  }

  //----------------------------------------------------------------------

  /// Analyzes the distance between two nodes and updates the current node's parent, g, and h values
  @override
  void analyzeDistance(ANode current, ANode end, {required ANode parent}) {
    current.parent = parent;
    current.g = parent.g + current.weight;
    // make short distance stronger by multiply by 2.0
    current.h = _distance(current, end);
  }

  /// Calculates the distance between two nodes.
  /// 6 triangle zone , calculate for each zone correct func
  int _distance(ANode from, ANode to) {
    if (from.y >= to.y) {
      // 1
      if (from.x >= to.x) {
        return (from.x - to.x).abs() + (from.y - to.y);
      }
      // 2
      if ((from.x + from.y) >= (to.x + to.y)) return from.y - to.y;
      // 3
      return (to.x - from.x).abs();
    }
    // 4
    if (to.x >= from.x) {
      return (from.x - to.x).abs() + (from.y - to.y).abs();
    }
    // 5
    if ((to.x + to.y) < (from.x + from.y)) return (from.x - to.x).abs();
    // 6
    return to.y - from.y;
  }

  /// Checks if two points are neighbors on a hexagonal grid.
  bool _isNeighbors(
    Point<int> a,
    Point<int> b,
  ) {
    ///      0,-1;  +1 -1
    /// -1,0 ; center ;  +1,0
    ///     -1,+1;  0,+1
    var top = a.y >= b.y ? a : b;
    var bot = a.y >= b.y ? b : a;

    // top
    if ((top.x == bot.x || top.x == bot.x + 1) && top.y == bot.y - 1) {
      return true;
    }
    // middle
    if ((top.x == bot.x + 1 || top.x == bot.x - 1) && top.y == bot.y) {
      return true;
    }
    // bottom
    if ((top.x == bot.x - 1 || top.x == bot.x) && top.y == bot.y + 1) {
      return true;
    }
    return false;
  }

  /// Adds neighbors to each node in the grid.
  @override
  void addNeighbors() {
    for (int y = 0; y < grid.height; y++) {
      for (int x = 0; x < grid.width; x++) {
        final node = grid[x][y];
        node.reset();
        node.neighbors.clear();
        _chainNeighbors(node);
      }
    }
  }

  /// Connects a node to its neighbors on a hexagonal grid.
  void _chainNeighbors(
    ANode node,
  ) {
    final x = node.x;
    final y = node.y;

    /// adds in left
    if (x > 0) {
      final t = grid[x - 1][y];
      if (!t.isBarrier) {
        node.neighbors.add(t);
      }
    }

    /// adds in right
    if (x < (grid.width - 1)) {
      final t = grid[x + 1][y];
      if (!t.isBarrier) {
        node.neighbors.add(t);
      }
    }

    /// adds in top
    if (y > 0) {
      final t = grid[x][y - 1];
      if (!t.isBarrier) {
        node.neighbors.add(t);
      }
      if (x < (grid.width - 1)) {
        final t2 = grid[x + 1][y - 1];
        if (!t2.isBarrier) {
          node.neighbors.add(t2);
        }
      }
    }

    /// adds in bottom
    if (y < (grid.height - 1)) {
      final t = grid[x][y + 1];
      if (!t.isBarrier) {
        node.neighbors.add(t);
      }

      if (x > 0) {
        final t2 = grid[x - 1][y + 1];
        if (!t2.isBarrier) {
          node.neighbors.add(t2);
        }
      }
    }
  }
}
