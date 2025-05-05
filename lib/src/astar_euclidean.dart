import 'dart:math';

import '../astar_dart.dart';

class AStarEuclidean extends AstarGrid {
  AStarEuclidean({
    required int rows,
    required int columns,
    required GridBuilder gridBuilder,
  }) : super(rows: rows, columns: columns, gridBuilder: gridBuilder);

  @override
  List<ANode> findPath({
    void Function(List<Point<int>>)? doneList,
    required ({int x, int y}) start,
    required ({int x, int y}) end,
  }) {
    this.doneList.clear();
    waitList.clear();

    if (grid[end.x][end.y].barrier.isBlock) {
      return [];
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
    doneList?.call(this.doneList.map((e) => Point(e.x, e.y)).toList());

    if (winner == null && !_isNeighbors(start, end)) {
      path.clear();
    }

    return path.toList();
  }

//----------------------------------------------------------------------
  ANode? _getWinner(ANode current, ANode end) {
    if (end == current) return current;
    // first iteration
    for (var n in current.neighbors) {
      if (n.parent == null) {
        _checkDistance(n, end, parent: current);
      }
      if (!doneList.contains(n)) {
        waitList.add(n);
        doneList.add(n);
      }
    }
    waitList.sort((a, b) => b.compareTo(a));

    // loop iteration
    while (waitList.isNotEmpty) {
      final c = waitList.removeLast();
      if (end == c) return c;
      for (var n in c.neighbors) {
        if (n.parent == null) {
          _checkDistance(n, end, parent: c);
        }
        if (!doneList.contains(n)) {
          waitList.add(n);
          doneList.add(n);
        }
      }
      waitList.sort((a, b) => b.compareTo(a));
    }

    return null;
  }

//----------------------------------------------------------------------

  void _checkDistance(ANode current, ANode end, {required ANode parent}) {
    current.parent = parent;
    current.g = parent.g + current.weight;
    current.h = _distance(current, end) * 1.0;
  }

  int _distance(ANode a, ANode b) {
    int toX = a.x - b.x;
    int toY = a.y - b.y;
    return toX.abs() + toY.abs();
  }

  bool _isNeighbors(({int x, int y}) start, ({int x, int y}) end) {
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
        node.parent = null;
        node.g = 0.0;
        node.h = 0.0;
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
      if (!grid[x][y - 1].barrier.isBlock) {
        node.neighbors.add(neighbor);
      }
    }
    if (y < maxY) {
      // Bottom
      final neighbor = grid[x][y + 1];
      if (!grid[x][y + 1].barrier.isBlock) {
        node.neighbors.add(neighbor);
      }
    }

    if (x > 0) {
      // Left
      final neighbor = grid[x - 1][y];
      if (!grid[x - 1][y].barrier.isBlock) {
        node.neighbors.add(neighbor);
      }
    }
    if (x < maxX) {
      // Right
      final neighbor = grid[x + 1][y];
      if (!grid[x + 1][y].barrier.isBlock) {
        node.neighbors.add(neighbor);
      }
    }

    // Diagonals
    if (x > 0 && y > 0) {
      // Top-Left
      final neighbor = grid[x - 1][y - 1];
      if (!grid[x - 1][y - 1].barrier.isBlock) {
        node.neighbors.add(neighbor);
      }
    }
    if (x > 0 && y < maxY) {
      // Bottom-Left
      final neighbor = grid[x - 1][y + 1];
      if (!grid[x - 1][y + 1].barrier.isBlock) {
        node.neighbors.add(neighbor);
      }
    }
    if (x < maxX && y > 0) {
      // Top-Right
      final neighbor = grid[x + 1][y - 1];
      if (!grid[x + 1][y - 1].barrier.isBlock) {
        node.neighbors.add(neighbor);
      }
    }

    if (x < maxX && y < maxY) {
      // Bottom-Right
      final neighbor = grid[x + 1][y + 1];
      if (!grid[x + 1][y + 1].barrier.isBlock) {
        node.neighbors.add(neighbor);
      }
    }
  }
}
