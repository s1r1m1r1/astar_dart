import 'dart:async';
import 'dart:math';

import '../astar_dart.dart';

class AStarEuclidean {
  final int _rows;
  final int _columns;
  late Point<int> _start;
  late Point<int> _end;
  late final Array2d<Barrier> _barriers;
  late final Array2d<int> _grounds;

  final List<ANode> _doneList = [];
  final List<ANode> _waitList = [];

  late Array2d<ANode> _grid;

  AStarEuclidean({
    required int rows,
    required int columns,
    Array2d<Barrier>? barriers,
    Array2d<int>? grounds,
  })  : _rows = rows,
        _columns = columns {
    _grounds = grounds ?? Array2d<int>(rows, columns, defaultValue: 1);
    _barriers =
        barriers ?? Array2d<Barrier>(rows, columns, defaultValue: Barrier.pass);
    _grid = Array2d(rows, columns, defaultValue: ANode.wrong);
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
    _start = start;
    _end = end;

    if (_barriers[_end.x][_end.y].isBlock) {
      return Future.value([]);
    }

    ANode startNode = _grid[_start.x][_start.y];

    ANode endNode = _grid[_end.x][_end.y];
    if (_isNeighbors(start, end)) {
      return [];
    }
    _addNeighbors();

    ANode? winner = _getWinner(
      startNode,
      endNode,
    );

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

    return sqrt(toX * toX + toY * toY); // Standard Euclidean distance
  }

  bool _isNeighbors(Point<int> start, Point<int> end) {
    int dx = (start.x - end.x).abs();
    int dy = (start.y - end.y).abs();

    return dx <= 1 && dy <= 1;
  }

  /// Adds neighbors to cells
  void _addNeighbors() {
    for (var row in grid.array) {
      for (ANode node in row) {
        node.parent = null;
        node.g = 0.0;

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
          if (!_barriers[nx][ny].isBlock) {
            node.neighbors.add(neighbor);
          }
        }
      }
    }
  }

  Array2d<ANode> get grid => _grid;
}
