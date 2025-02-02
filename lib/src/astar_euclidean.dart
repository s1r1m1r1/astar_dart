import 'dart:async';
import 'dart:math';

import '../astar_dart.dart';

class AStarEuclidean extends AstarGrid {
  AStarEuclidean({
    required int rows,
    required int columns,
    required GridBuilder gridBuilder,
  }) : super(rows: rows, columns: columns, gridBuilder: gridBuilder);

  @override
  FutureOr<List<ANode>> findPath({
    void Function(List<Point<int>>)? doneList,
    required ({int x, int y}) start,
    required ({int x, int y}) end,
  }) {
    super.doneList.clear();
    super.waitList.clear();

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
    doneList?.call(super.doneList.map((e) => Point(e.x, e.y)).toList());

    if (winner == null && !_isNeighbors(start, end)) {
      path.clear();
    }

    return Future.value(path.toList());
  }

  ANode? _getWinner(ANode current, ANode end) {
    if (end == current) return current;
    for (var n in current.neighbors) {
      if (n.parent == null) {
        _checkDistance(n, end, parent: current);
      }
      if (!super.doneList.contains(n)) {
        super.waitList.add(n);
        super.doneList.add(n);
      }
    }

    while (super.waitList.isNotEmpty) {
      final c = super.waitList.removeLast();
      if (end == c) return c;
      for (var n in c.neighbors) {
        if (n.parent == null) {
          _checkDistance(n, end, parent: c);
        }
        if (!super.doneList.contains(n)) {
          super.waitList.add(n);
        }
      }
      super.doneList.add(c);
      super.waitList.sort((a, b) => b.compareTo(a));
    }

    return null;
  }

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
