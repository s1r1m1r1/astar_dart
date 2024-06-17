import 'dart:math';
// import 'package:collection/collection.dart';

import '../astar_dart.dart';
import 'astar_grid.dart';
import 'package:meta/meta.dart';

class AStarSquareGrid extends AstarGrid {
  final int _rows;
  final int _columns;
  late Point<int> _start;
  late Point<int> _end;
  late final _random = Random();
  late final Array2d<Barrier> _barriers;
  late final Array2d<int> _grounds;

  late DiagonalMovement _diagonalMovement;
  final List<ANode> _doneList = [];
  final List<ANode> _waitList = [];

  late Array2d<ANode> _grid;

  AStarSquareGrid({
    required int rows,
    required int columns,
    DiagonalMovement diagonalMovement = DiagonalMovement.euclidean,
  })  : _rows = rows,
        _columns = columns,
        _diagonalMovement = diagonalMovement {
    _grounds = Array2d<int>(rows, columns, defaultValue: 1);
    _barriers = Array2d<Barrier>(rows, columns, defaultValue: Barrier.pass);
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
  @override
  Future<List<ANode>> findPath(
      {void Function(List<Point<int>>)? doneList,
      required Point<int> start,
      required Point<int> end}) {
    _start = start;
    _end = end;
    _doneList.clear();
    _waitList.clear();

    if (_barriers[_end.x][_end.y].isBlock) {
      return Future.value([]);
    }

    ANode startNode = _grid[_start.x][_start.y];

    ANode endNode = _grid[_end.x][_end.y];
    if (_isNeighbors(start, end)) {
      return Future.value([endNode]);
    }
    _addNeighbors();
    ANode? winner = _getANodeWinner(
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

  @experimental
  double _estimateDistance(Point<int> target) {
    // Implement a simple heuristic to estimate distance (e.g., Manhattan distance)
    final dx = (_start.x - target.x).abs();
    final dy = (_start.y - target.y).abs();
    return (dx + dy).toDouble();
  }

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
  List<Point<int>> findSteps({required int steps, required Point<int> start}) {
    _addNeighbors();

    ANode startANode = _grid[start.x][start.y];
    final List<ANode> totalArea = [startANode];
    final List<ANode> waitArea = [];

    final List<ANode> currentArea = [...startANode.neighbors];
    if (currentArea.isEmpty) {
      return totalArea.map((node) => Point(node.x, node.y)).toList();
    }
    for (var element in startANode.neighbors) {
      element.parent = startANode;
      element.g = element.weight + startANode.weight;
    }
    for (var i = 1; i < steps + 2; i++) {
      if (currentArea.isEmpty) continue;
      for (var currentANode in currentArea) {
        if (currentANode.g <= i) {
          totalArea.add(currentANode);
          for (var n in currentANode.neighbors) {
            if (totalArea.contains(n)) continue;
            if (n.parent == null) {
              n.parent = currentANode;
              n.g = n.weight + currentANode.g;
            }
            waitArea.add(n);
          }
        } else {
          waitArea.add(currentANode);
        }
      }
      currentArea.clear();
      currentArea.addAll(waitArea);
      waitArea.clear();
    }
    return totalArea.map((node) => Point(node.x, node.y)).toList();
  }

  /// MIT
  /// https://github.com/RafaelBarbosatec/a_star/blob/main/lib/a_star_algorithm.dart
  /// Method recursive that execute the A* algorithm
  ANode? _getANodeWinner(ANode current, ANode end) {
    _waitList.remove(current);
    if (end == current) return current;
    final isReversed = _random.nextBool();
    for (int i = 0; i < current.neighbors.length; i++) {
      final index = isReversed ? current.neighbors.length - (i + 1) : i;
      final n = current.neighbors[index];
      if (n.parent == null) {
        _analiseDistance(n, end, parent: current);
      }
      if (!_doneList.contains(n)) {
        _waitList.add(n);
      }
    }

    _doneList.add(current);
    _waitList.sort((a, b) {
      return a.f.compareTo(b.f);
    });
    for (var i = 0; i < _waitList.length; i++) {}
    for (final element in _waitList) {
      if (!_doneList.contains(element)) {
        final result = _getANodeWinner(element, end);
        return result;
      }
    }

    return null;
  }

  void _analiseDistance(ANode current, ANode end, {required ANode parent}) {
    current.parent = parent;
    current.g = parent.g + current.weight;
    current.h = _distance(current, end);
  }

  /// Calculates the distance between two nodes.
  double _distance(ANode current, ANode target) {
    int toX = current.x - target.x;
    int toY = current.y - target.y;
    return Point(toX, toY).magnitude * 2;
  }

  bool _isNeighbors(Point<int> start, Point<int> end) {
    if (_diagonalMovement == DiagonalMovement.euclidean) {
      if (start.x + 1 == end.x && start.y - 1 == end.y ||
          start.x + 1 == end.x && start.y + 1 == end.y ||
          start.x - 1 == end.x && start.y - 1 == end.y ||
          start.x - 1 == end.x && start.y + 1 == end.y) {
        return true;
      }
    }
    if (_diagonalMovement == DiagonalMovement.manhattan) {
      if ((start.x + 1 == end.x || start.x - 1 == end.x) && start.y == end.y ||
          (start.y + 1 == end.y || start.y - 1 == end.y) && start.x == end.x) {
        return true;
      }
    }
    return false;
  }

  /// Adds neighbors to cells
  void _addNeighbors() {
    for (var row in _grid.array) {
      for (ANode node in row) {
        _chainNeigbors(node);
      }
    }
  }

  void _chainNeigbors(
    ANode node,
  ) {
    final x = node.x;
    final y = node.y;

    /// adds in top
    if (y > 0) {
      final t = _grid[x][y - 1];
      if (!_barriers[t.x][t.y].isBlock) {
        node.neighbors.add(t);
      }
    }

    /// adds in bottom
    if (y < (_grid.first.length - 1)) {
      final t = _grid[x][y + 1];
      if (!_barriers[t.x][t.y].isBlock) {
        node.neighbors.add(t);
      }
    }

    /// adds in left
    if (x > 0) {
      final t = _grid[x - 1][y];
      if (!_barriers[t.x][t.y].isBlock) {
        node.neighbors.add(t);
      }
    }

    /// adds in right
    if (x < (_grid.length - 1)) {
      final t = _grid[x + 1][y];
      if (!_barriers[t.x][t.y].isBlock) {
        node.neighbors.add(t);
      }
    }

    if (_diagonalMovement == DiagonalMovement.euclidean) {
      /// adds in top-left
      if (y > 0 && x > 0) {
        final t = _grid[x - 1][y - 1];
        if (!_barriers[t.x][t.y].isBlock) {
          node.neighbors.add(t);
        }
      }

      /// adds in top-right
      if (y > 0 && x < (_grid.length - 1)) {
        final t = _grid[x + 1][y - 1];
        if (!_barriers[t.x][t.y].isBlock) {
          node.neighbors.add(t);
        }
      }

      /// adds in bottom-left
      if (x > 0 && y < (_grid.first.length - 1)) {
        final t = _grid[x - 1][y + 1];
        if (!_barriers[t.x][t.y].isBlock) {
          node.neighbors.add(t);
        }
      }

      /// adds in bottom-right
      if (x < (_grid.length - 1) && y < (_grid.first.length - 1)) {
        final t = _grid[x + 1][y + 1];
        if (!_barriers[t.x][t.y].isBlock) {
          node.neighbors.add(t);
        }
      }
    }
  }

  @visibleForTesting
  Array2d<ANode> get grid => _grid;
}
