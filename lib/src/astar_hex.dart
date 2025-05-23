import 'dart:math';

import 'package:astar_dart/astar_dart.dart';

class AStarHex extends AstarGrid {
  AStarHex({
    required int rows,
    required int columns,
    required GridBuilder gridBuilder,
  }) : super(
          rows: rows,
          columns: columns,
          gridBuilder: gridBuilder,
        );

  @override
  List<ANode> findPath({
    void Function(List<Point<int>>)? visited,
    required ({int x, int y}) start,
    required ({int x, int y}) end,
  }) {
    /// If the end node is blocked, return an empty path.
    if (grid[end.x][end.y].barrier == Barrier.block) {
      return [];
    }

    /// Get the start and end nodes from the grid.
    ANode startNode = grid[start.x][start.y];
    ANode endNode = grid[end.x][end.y];

    /// If start and end are neighbors, return a direct path.
    if (_isNeighbors(start, end)) {
      return [endNode];
    }

    /// Find the best path using the A* algorithm.

    ANode? winner = getWinner(
      startNode,
      endNode,
    );

    /// Reconstruct the path from the winner node.
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

    /// If no path was found, clear the path list.
    if (winner == null) {
      path.clear();
    }
    waitList.clear();
    doneList.clear();

    /// Call the doneList callback with the explored nodes.
    visited?.call(doneList.map((e) => Point(e.x, e.y)).toList());

    return path.toList();
  }

  //----------------------------------------------------------------------

  /// Analyzes the distance between two nodes and updates the current node's parent, g, and h values
  @override
  void analyzeDistance(ANode current, ANode end, {required ANode parent}) {
    current.parent = parent;
    current.g = parent.g + current.weight;
    // make short distance stronger by multiply by 2.0
    current.h = _distance(current, end) * 2.0;
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
    ({int x, int y}) a,
    ({int x, int y}) b,
  ) {
    ///      0,-1;  +1 -1
    /// -1,0 ; center:0,0;  +1,0
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
    for (var row in grid.array) {
      for (ANode node in row) {
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
      if (t.barrier != Barrier.block) {
        node.neighbors.add(t);
      }
    }

    /// adds in right
    if (x < (grid.length - 1)) {
      final t = grid[x + 1][y];
      if (t.barrier != Barrier.block) {
        node.neighbors.add(t);
      }
    }

    /// adds in top
    if (y > 0) {
      final t = grid[x][y - 1];
      if (t.barrier != Barrier.block) {
        node.neighbors.add(t);
      }
      if (x < (grid.length - 1)) {
        final t2 = grid[x + 1][y - 1];
        if (t2.barrier != Barrier.block) {
          node.neighbors.add(t2);
        }
      }
    }

    /// adds in bottom
    if (y < (grid.first.length - 1)) {
      final t = grid[x][y + 1];
      if (t.barrier != Barrier.block) {
        node.neighbors.add(t);
      }

      if (x > 0) {
        final t2 = grid[x - 1][y + 1];
        if (t2.barrier != Barrier.block) {
          node.neighbors.add(t2);
        }
      }
    }
  }
}
