import 'dart:math';

import 'package:astar_dart/astar_dart.dart';

class AStarEuclidean extends AstarGrid {
  AStarEuclidean({
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
    if (grid[end.x][end.y].isBarrier) {
      return [];
    }

    ANode startNode = grid[start.x][start.y];
    ANode endNode = grid[end.x][end.y];

    if (_isNeighbors(start, end)) {
      return [];
    }
    startNode.visited = true;
    startNode.g = 0;
    ANode? winner = getWinner(
      startNode,
      endNode,
    );

    if (winner != null) {
      final path = reconstructNormalized(winner);
      return path;
    }

    visited?.call(grid.whereabout((i) => i.visited).toList());

    return [];
  }

//----------------------------------------------------------------------

  @override
  void analyzeDistance(ANode current, ANode end, {required ANode parent}) {
    current.parent = parent;
    current.g = parent.g + current.weight;
    current.h = _distance(current, end) * 2;
  }

  int _distance(ANode a, ANode b) {
    int toX = a.x - b.x;
    int toY = a.y - b.y;
    return toX.abs() + toY.abs();
  }

  bool _isNeighbors(Point<int> start, Point<int> end) {
    int dx = (start.x - end.x).abs();
    int dy = (start.y - end.y).abs();

    return dx <= 1 && dy <= 1;
  }

  /// Adds neighbors to cells
  @override
  void addNeighbors() {
    final maxX = grid.length - 1;
    final maxY = grid.first.length - 1;
    for (var row in grid.array) {
      for (ANode node in row) {
        // node.reset();
        node.parent = null;
        node.h = 0;
        node.g = 0;
        node.neighbors.clear();
        _chainNeighbors(node, maxX: maxX, maxY: maxY);
      }
    }
  }

  void _chainNeighbors(ANode node, {required int maxX, required int maxY}) {
    final x = node.x;
    final y = node.y;
    if (y > 0) {
      // Top
      final neighbor = grid[x][y - 1];
      if (!neighbor.isBarrier) {
        node.neighbors.add(neighbor);
      }
    }
    if (y < maxY) {
      // Bottom
      final neighbor = grid[x][y + 1];
      if (!neighbor.isBarrier) {
        node.neighbors.add(neighbor);
      }
    }

    if (x > 0) {
      // Left
      final neighbor = grid[x - 1][y];
      if (!neighbor.isBarrier) {
        node.neighbors.add(neighbor);
      }
    }
    if (x < maxX) {
      // Right
      final neighbor = grid[x + 1][y];
      if (!neighbor.isBarrier) {
        node.neighbors.add(neighbor);
      }
    }

    // Diagonals
    if (x > 0 && y > 0) {
      // Top-Left
      final neighbor = grid[x - 1][y - 1];
      if (!neighbor.isBarrier) {
        node.neighbors.add(neighbor);
      }
    }
    if (x > 0 && y < maxY) {
      // Bottom-Left
      final neighbor = grid[x - 1][y + 1];
      if (!neighbor.isBarrier) {
        node.neighbors.add(neighbor);
      }
    }
    if (x < maxX && y > 0) {
      // Top-Right
      final neighbor = grid[x + 1][y - 1];
      if (!neighbor.isBarrier) {
        node.neighbors.add(neighbor);
      }
    }

    if (x < maxX && y < maxY) {
      // Bottom-Right
      final neighbor = grid[x + 1][y + 1];
      if (!neighbor.isBarrier) {
        node.neighbors.add(neighbor);
      }
    }
  }
}
