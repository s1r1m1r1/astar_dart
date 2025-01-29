import 'dart:async';
import 'dart:math';
// import 'package:collection/collection.dart';

import '../astar_dart.dart';

import 'astar_grid.dart';

class AStarManhattan extends AstarGrid {
  final List<ANode> _doneList = [];
  final List<ANode> _waitList = [];

  AStarManhattan({
    required int rows,
    required int columns,
    Array2d<Barrier>? barriers,
    Array2d<int>? grounds,
  }) : super(
          rows: rows,
          columns: columns,
          barriers: barriers ??
              Array2d<Barrier>(rows, columns,
                  valueBuilder: (x, y) => Barrier.pass),
          grounds:
              grounds ?? Array2d<int>(rows, columns, valueBuilder: (x, y) => 1),
        );

  void setBarrier(BarrierPoint point) {
    assert(point.x <= rows, "Point can't be bigger than Array2d rows");
    assert(point.y <= columns, "Point can't be bigger than Array2d column");
    barriers[point.x][point.y] = point.barrier;
  }

  void setBarriers(List<BarrierPoint> points) {
    for (final point in points) {
      assert(point.x <= rows, "Point can't be bigger than Array2d rows");
      assert(point.y <= columns, "Point can't be bigger than Array2d columns");

      barriers[point.x][point.y] = point.barrier;
    }
  }

  void setPoint(WeightedPoint point) {
    assert(point.x <= rows, "Point can't be bigger than Array2d rows");
    assert(point.y <= columns, "Point can't be bigger than Array2d columns");
    grounds[point.x][point.y] = point.weight;
  }

  void setPoints(List<WeightedPoint> points) {
    for (final point in points) {
      assert(point.x <= rows, "Point can't be bigger than Array2d rows");
      assert(point.y <= columns, "Point can't be bigger than Array2d columns");
      grounds[point.x][point.y] = point.weight;
    }
  }

  void calculateGrid() {
    _createGrid(rows: rows, columns: columns);
  }

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

    if (barriers[end.x][end.y].isBlock) {
      return [];
    }

    ANode startNode = grid[start.x][start.y];

    ANode endNode = grid[end.x][end.y];
    if (_isNeighbors(start, end)) {
      return [];
    }
    addNeighbors();

    ANode? winner = _getWinner(
      startNode,
      endNode,
    );
    print('winner ${winner?.g}');
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
      _waitList.sort((a, b) => b.f.compareTo(a.f));
    }

    return winner;
  }

  void _checkDistance(ANode current, ANode end, {required ANode parent}) {
    current.parent = parent;
    current.g = parent.g + current.weight;
    current.h = _distance(current, end);
  }

  /// Calculates the distance between two nodes.
  double _distance(ANode current, ANode target) {
    int toX = current.x - target.x;
    int toY = current.y - target.y;
    return (toX.abs() + toY.abs()).toDouble();
  }

  bool _isNeighbors(Point<int> start, Point<int> end) {
    int dx = (start.x - end.x).abs();
    int dy = (start.y - end.y).abs();

    // Manhattan
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
  }

  /// Adds neighbors to cells
  @override
  void addNeighbors() {
    for (var row in grid.array) {
      for (ANode node in row) {
        node.parent = null;
        node.g = 0.0;
        _chainNeighborsManhattan(node);
      }
    }
  }

  void _chainNeighborsManhattan(ANode node) {
    final x = node.x;
    final y = node.y;
    final maxX = grid.length - 1;
    final maxY = grid.first.length - 1;

    // Optimized neighbor adding for Manhattan distance (only cardinal directions)
    if (y > 0) {
      // Top
      final neighbor = grid[x][y - 1];
      if (!barriers[x][y - 1].isBlock) {
        node.neighbors.add(neighbor);
      }
    }
    if (y < maxY) {
      // Bottom
      final neighbor = grid[x][y + 1];
      if (!barriers[x][y + 1].isBlock) {
        node.neighbors.add(neighbor);
      }
    }
    if (x > 0) {
      // Left
      final neighbor = grid[x - 1][y];
      if (!barriers[x - 1][y].isBlock) {
        node.neighbors.add(neighbor);
      }
    }
    if (x < maxX) {
      // Right
      final neighbor = grid[x + 1][y];
      if (!barriers[x + 1][y].isBlock) {
        node.neighbors.add(neighbor);
      }
    }
  }
}
