import 'dart:async';
import 'dart:math';
// import 'package:collection/collection.dart';

import '../astar_dart.dart';
import 'package:meta/meta.dart';

class AStarSquare {
  final int _rows;
  final int _columns;
  late Point<int> _start;
  late Point<int> _end;
  late final Array2d<Barrier> _barriers;
  late final Array2d<int> _grounds;

  late DiagonalMovement _diagonalMovement;
  final List<ANode> _doneList = [];
  final List<ANode> _waitList = [];

  late Array2d<ANode> _grid;

  AStarSquare({
    required int rows,
    required int columns,
    Array2d<Barrier>? barriers,
    Array2d<int>? grounds,
    DiagonalMovement diagonalMovement = DiagonalMovement.euclidean,
  })  : _rows = rows,
        _columns = columns,
        _diagonalMovement = diagonalMovement {
    _grounds = grounds ?? Array2d<int>(rows, columns, defaultValue: 1);
    _barriers =
        barriers ?? Array2d<Barrier>(rows, columns, defaultValue: Barrier.pass);
    _grid = Array2d(rows, columns, defaultValue: ANode.wrong);
  }
  void setDiagonalMovement(DiagonalMovement diagonalMovement) {
    _diagonalMovement = diagonalMovement;
  }

  void setBarrier(BarrierPoint point) {
    assert(point.x <= _rows, "Point can't be bigger than Array2d rows");
    assert(point.y <= _columns, "Point can't be bigger than Array2d column");
    _barriers[point.x][point.y] = point.barrier;
  }

  void setBarriers(List<BarrierPoint> points) {
    for (final point in points) {
      assert(point.x <= _rows, "Point can't be bigger than Array2d rows");
      assert(point.y <= _columns, "Point can't be bigger than Array2d columns");

      _barriers[point.x][point.y] = point.barrier;
    }
  }

  void setPoint(WeightedPoint point) {
    assert(point.x <= _rows, "Point can't be bigger than Array2d rows");
    assert(point.y <= _columns, "Point can't be bigger than Array2d columns");
    _grounds[point.x][point.y] = point.weight;
  }

  void setPoints(List<WeightedPoint> points) {
    for (final point in points) {
      assert(point.x <= _rows, "Point can't be bigger than Array2d rows");
      assert(point.y <= _columns, "Point can't be bigger than Array2d columns");
      _grounds[point.x][point.y] = point.weight;
    }
  }

  void calculateGrid() {
    _createGrid(rows: _rows, columns: _columns);
  }

  /// return full path without Start position
  /// for Point(0,0) to Point(0,3) result will be [Point(0,3),Point(0,2),Point(0,1)]
  /// ```dart
  /// final result = _astar.findPath(start: Point(0,0),end: Point(0,3));
  /// final moveTo = result.removeLast();
  /// final moveNext = result.removeLast();
  /// ```
  FutureOr<List<ANode>> findPath({
    void Function(List<Point<int>>)? doneList,
    required Point<int> start,
    required Point<int> end,
  }) {
    print("ONe");
    _start = start;
    _end = end;

    print("TWO");
    if (_barriers[_end.x][_end.y].isBlock) {
      return Future.value([]);
    }

    print("3");
    ANode startNode = _grid[_start.x][_start.y];

    ANode endNode = _grid[_end.x][_end.y];
    if (_isNeighbors(start, end)) {
      return Future.value([]);
    }
    print("4");
    _addNeighbors();

    print("5");
    ANode? winner = _getWinner(
      startNode,
      endNode,
    );

    print("6");

    List<ANode> path = [_grid[_end.x][_end.y]];
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

    if (winner == null && !_isNeighbors(_start, _end)) {
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
        _grid[x][y] = ANode(
          x: x,
          y: y,
          neighbors: [],
          weight: _grounds[x][y].toDouble(),
        );
      }
    }
  }

  // @experimental
  // ANode? _findFirstTarget(List<Point<int>> availableTargets) {
  //   final pq = PriorityQueue<Point<int>>(
  //       (a, b) => _estimateDistance(a).compareTo(_estimateDistance(b)));

  //   // Add targets with estimated distances to the priority queue
  //   for (final target in availableTargets) {
  //     pq.add(target);
  //   }

  //   while (pq.isNotEmpty) {
  //     final target = pq.removeFirst();
  //     final path = findPath(start: _start, end: target);
  //     if (path.isNotEmpty) {
  //       return _grid[_end.x][_end.y]; // Update target node on the grid
  //     }
  //   }

  //   return null;
  // }

  /// find steps area , useful for Turn Based Game
  /// example 3 steps
  /// ```
  ///          3
  ///       3  2  3
  ///    3  2  1  2  3
  /// 3  2  1  🧍‍♂️ 1  2  3
  ///    3  2  1  2  3
  ///       3  2  3
  ///          3
  /// ```
  Future<List<Point<int>>> findSteps(
      {required int steps, required Point<int> start}) async {
    _addNeighbors();

    ANode a = _grid[start.x][start.y];
    final List<ANode> total = [a];
    final List<ANode> next = [];

    final List<ANode> current = [...a.neighbors];
    if (current.isEmpty) {
      return Future.value(total.map((node) => Point(node.x, node.y)).toList());
    }
    for (var element in a.neighbors) {
      element.parent = a;
      element.g = element.weight + 0;
    }
    current.sort((a, b) => a.g.compareTo(b.g));
    while (current.isNotEmpty) {
      for (var c in current) {
        if (c.g <= steps ) {
          if (!total.contains(c)) total.add(c);
          for (var n in c.neighbors) {
            if (total.contains(n)) continue;
            if (n.parent == null) {
              n.parent = c;
              n.g = n.weight + c.g;
            }
            if (!next.contains(n) && !total.contains(n)) next.add(n);
          }
        }
      }
      current.clear();
      current.addAll(next);
      current.sort((a, b) => a.g.compareTo(b.g));
      next.clear();
    }

    return Future.value(total.map((node) => Point(node.x, node.y)).toList());
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
    current.h = _distance(current, end);
  }

  /// Calculates the distance between two nodes.
  double _distance(ANode current, ANode target) {
    int toX = current.x - target.x;
    int toY = current.y - target.y;

    if (_diagonalMovement == DiagonalMovement.manhattan) {
      return (toX.abs() + toY.abs()).toDouble();
    } else {
      // Euclidean or Chebyshev
      return sqrt(toX * toX + toY * toY); // Standard Euclidean distance
    }
  }

  bool _isNeighbors(Point<int> start, Point<int> end) {
    int dx = (start.x - end.x).abs();
    int dy = (start.y - end.y).abs();

    if (_diagonalMovement == DiagonalMovement.euclidean ||
        _diagonalMovement == DiagonalMovement.chebychev) {
      return dx <= 1 && dy <= 1;
    } else {
      // Manhattan
      return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
    }
  }

  /// Adds neighbors to cells
  void _addNeighbors() {
    for (var row in _grid.array) {
      for (ANode node in row) {
       node.parent = null;
        node.g = 0.0;
        if (_diagonalMovement == DiagonalMovement.manhattan) {
          _chainNeighborsManhattan(node);
        } else {
          _chainNeighbors(node);
        }
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
          if (!_barriers[nx][ny].isBlock) {
            node.neighbors.add(neighbor);
          }
        }
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
      if (!_barriers[x][y - 1].isBlock) {
        node.neighbors.add(neighbor);
      }
    }
    if (y < maxY) {
      // Bottom
      final neighbor = grid[x][y + 1];
      if (!_barriers[x][y + 1].isBlock) {
        node.neighbors.add(neighbor);
      }
    }
    if (x > 0) {
      // Left
      final neighbor = grid[x - 1][y];
      if (!_barriers[x - 1][y].isBlock) {
        node.neighbors.add(neighbor);
      }
    }
    if (x < maxX) {
      // Right
      final neighbor = grid[x + 1][y];
      if (!_barriers[x + 1][y].isBlock) {
        node.neighbors.add(neighbor);
      }
    }
  }

  @visibleForTesting
  Array2d<ANode> get grid => _grid;
}
