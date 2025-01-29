import 'dart:async';
import 'dart:math';

import 'dart:developer' as developer;
import 'package:meta/meta.dart';

import '../astar_dart.dart';
import 'astar_grid.dart';

enum AStarHexAlignment {
  odd,
  even,
}

class AStarHex extends AstarGrid {
  final List<ANode> _doneList = [];
  final List<ANode> _waitList = [];

  late AStarHexAlignment alignment;
  AStarHex.useList({
    required int rows,
    required int columns,
    List<BarrierPoint>? barriers,
    List<WeightedPoint>? grounds,
    this.alignment = AStarHexAlignment.even,
  }) : super(
          rows: rows,
          columns: columns,
          barriers: Array2d<Barrier>(rows, columns, defaultValue: Barrier.pass),
          grounds: Array2d<int>(rows, columns, defaultValue: 1),
        ) {
    if (barriers != null) {
      for (var b in barriers) {
        super.barriers[b.x][b.y] = Barrier.block;
      }
    }
    if (grounds != null) {
      for (var g in grounds) {
        super.grounds[g.x][g.y] = g.weight;
      }
    }
    _createGrid(rows: super.rows, columns: super.columns);
  }

  AStarHex({
    required int rows,
    required int columns,
    Array2d<Barrier>? barriers,
    Array2d<int>? grounds,
    this.alignment = AStarHexAlignment.even,
  }) : super(
          rows: rows,
          columns: columns,
          barriers: Array2d<Barrier>(rows, columns, defaultValue: Barrier.pass),
          grounds: Array2d<int>(rows, columns, defaultValue: 1),
        ) {
    grid = Array2d(rows, columns, defaultValue: ANode.wrong);
    _createGrid(rows: rows, columns: columns);
  }

  @override
  FutureOr<List<ANode>> findPath({
    void Function(List<Point<int>>)? doneList,
    required Point<int> start,
    required Point<int> end,
  }) async {
    super.start = start;
    super.end = end;
    _doneList.clear();
    _waitList.clear();

    if (super.barriers[super.end.x][super.end.y].isBlock) {
      return [];
    }

    ANode startNode = grid[start.x][start.y];

    ANode endNode = grid[end.x][end.y];
    if (_isNeighbors(start, end)) {
      return Future.value([endNode]);
    }
    addNeighbors();

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

    doneList?.call(_doneList.map((e) => Point(e.x, e.y)).toList());

    if (winner == null) {
      path.clear();
    }

    return Future.value(path.toList());
  }

  void _createGrid({
    required int rows,
    required int columns,
  }) {
    for (int x = 0; x < rows; x++) {
      for (int y = 0; y < columns; y++) {
        grid[x][y] = ANode(
          x: x,
          y: y,
          neighbors: [],
          weight: grounds[x][y].toDouble(),
        );
      }
    }
  }

  ANode? _getWinner(ANode current, ANode end) {
    _waitList.clear();
    _doneList.clear();
    ANode? winner;
    if (end == current) return current;
    for (var n in current.neighbors) {
      if (n.parent == null) {
        _analyzeDistance(n, end, parent: current);
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
          _analyzeDistance(n, end, parent: c);
        }
        if (!_doneList.contains(n)) {
          _waitList.add(n);
        }
      }
      _doneList.add(c);
      _waitList.sort((a, b) => b.f.compareTo(a.f));
    }

    return winner;
  }

  void _analyzeDistance(ANode current, ANode end, {required ANode parent}) {
    current.parent = parent;

    /// minimal cost 1.414 diagonal
    current.g = parent.g + current.weight;

    current.h = _distance(current, end) * 1.0;
  }

  /// Calculates the distance between two nodes.
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

  bool _isNeighbors(Point<int> a, Point<int> b) {
    final s = (b - a);
    return (s.x.abs() <= 1 && s.y.abs() <= 1);
  }

  /// Adds neighbors to cells
  @internal
  @override
  void addNeighbors() {
    for (var row in grid.array) {
      for (ANode node in row) {
        node.parent = null;
        node.g = 0.0;
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
      if (!barriers[t.x][t.y].isBlock) {
        node.neighbors.add(t);
      }
    }

    /// adds in right
    if (x < (grid.length - 1)) {
      final t = grid[x + 1][y];
      if (!barriers[t.x][t.y].isBlock) {
        node.neighbors.add(t);
      }
    }

    /// adds in top
    if (y > 0) {
      final t = grid[x][y - 1];
      if (!barriers[t.x][t.y].isBlock) {
        node.neighbors.add(t);
      }
      if (x < (grid.length - 1)) {
        final t2 = grid[x + 1][y - 1];
        if (!barriers[t2.x][t2.y].isBlock) {
          node.neighbors.add(t2);
        }
      }
    }

    /// adds in bottom
    if (y < (grid.first.length - 1)) {
      final t = grid[x][y + 1];
      if (!barriers[t.x][t.y].isBlock) {
        node.neighbors.add(t);
      }

      if (x > 0) {
        final t2 = grid[x - 1][y + 1];
        if (!barriers[t2.x][t2.y].isBlock) {
          node.neighbors.add(t2);
        }
      }
    }
  }
}
