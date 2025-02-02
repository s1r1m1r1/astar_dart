import 'dart:async';
import 'dart:math';

import 'dart:developer' as developer;

import '../astar_dart.dart';

enum AStarHexAlignment {
  odd,
  even,
}

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
  FutureOr<List<ANode>> findPath({
    void Function(List<Point<int>>)? doneList,
    required ({int x, int y}) start,
    required ({int x, int y}) end,
  }) async {
    if (grid[end.x][end.y].barrier.isBlock) {
      return [];
    }

    ANode startNode = grid[start.x][start.y];

    ANode endNode = grid[end.x][end.y];
    if (_isNeighbors(start, end)) {
      return Future.value([endNode]);
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

    // developer.log("PATH:\n${path.length} $path\n\n");

    doneList?.call(super.doneList.map((e) => Point(e.x, e.y)).toList());

    if (winner == null) {
      path.clear();
    }

    return Future.value(path.toList());
  }

  ANode? _getWinner(ANode current, ANode end) {
    super.waitList.clear();
    super.doneList.clear();
    if (end == current) return current;
    for (var n in current.neighbors) {
      if (n.parent == null) {
        _analyzeDistance(n, end, parent: current);
      }
      if (!super.doneList.contains(n)) {
        super.waitList.add(n);
      }
    }

    while (super.waitList.isNotEmpty) {
      final c = super.waitList.removeLast();
      if (end == c) return c;
      for (var n in c.neighbors) {
        if (n.parent == null) {
          _analyzeDistance(n, end, parent: c);
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

  void _analyzeDistance(ANode current, ANode end, {required ANode parent}) {
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

  bool _isNeighbors(
    ({int x, int y}) a,
    ({int x, int y}) b,
  ) {
    final s1 = (b.x - a.x);
    final s2 = (b.y - a.y);

    return (s1.abs() <= 1 && s2.abs() <= 1);
  }

  /// Adds neighbors to cells
  @override
  void addNeighbors() {
    for (var row in grid.array) {
      for (ANode node in row) {
        node.parent = null;
        node.h = 0.0;
        node.g = 0.0;
        node.neighbors.clear();
        _chainNeighbors(node);
      }
    }
  }

  void _chainNeighbors(
    ANode node,
  ) {
    final x = node.x;
    final y = node.y;

    /// adds in left
    if (x > 0) {
      final t = grid[x - 1][y];
      if (!grid[t.x][t.y].barrier.isBlock) {
        node.neighbors.add(t);
      }
    }

    /// adds in right
    if (x < (grid.length - 1)) {
      final t = grid[x + 1][y];
      if (!grid[t.x][t.y].barrier.isBlock) {
        node.neighbors.add(t);
      }
    }

    /// adds in top
    if (y > 0) {
      final t = grid[x][y - 1];
      if (!grid[t.x][t.y].barrier.isBlock) {
        node.neighbors.add(t);
      }
      if (x < (grid.length - 1)) {
        final t2 = grid[x + 1][y - 1];
        if (!grid[t2.x][t2.y].barrier.isBlock) {
          node.neighbors.add(t2);
        }
      }
    }

    /// adds in bottom
    if (y < (grid.first.length - 1)) {
      final t = grid[x][y + 1];
      if (!grid[t.x][t.y].barrier.isBlock) {
        node.neighbors.add(t);
      }

      if (x > 0) {
        final t2 = grid[x - 1][y + 1];
        if (!grid[t2.x][t2.y].barrier.isBlock) {
          node.neighbors.add(t2);
        }
      }
    }
  }
}
