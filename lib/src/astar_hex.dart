import 'dart:math';

import 'dart:developer' as developer;
import 'package:meta/meta.dart';

import '../astar_dart.dart';

enum AStarHexAlignment {
  odd,
  even,
}

class AStarHex {
  final int _rows;
  final int _columns;
  late Point<int> _start;
  late Point<int> _end;
  late final Array2d<Barrier> _barriers;
  late final Array2d<int> _grounds;

  final List<AHexNode> _doneList = [];
  final List<AHexNode> _waitList = [];

  late Array2d<AHexNode> _grid;
  late AStarHexAlignment alignment;
  AStarHex.useList({
    required int rows,
    required int columns,
    List<BarrierPoint>? barriers,
    List<WeightedPoint>? grounds,
    this.alignment = AStarHexAlignment.even,
  })  : _rows = rows,
        _columns = columns {
    _barriers = Array2d<Barrier>(rows, columns, defaultValue: Barrier.pass);
    if (barriers != null) {
      for (var b in barriers) {
        _barriers[b.x][b.y] = Barrier.block;
      }
    }
    _grounds = Array2d<int>(rows, columns, defaultValue: 1);
    if (grounds != null) {
      for (var g in grounds) {
        _grounds[g.x][g.y] = g.weight;
      }
    }
    _grid = Array2d(rows, columns, defaultValue: AHexNode.wrong);
    _createGrid(rows: _rows, columns: _columns);
  }

  AStarHex({
    required int rows,
    required int columns,
    Array2d<Barrier>? barriers,
    Array2d<int>? grounds,
    this.alignment = AStarHexAlignment.even,
  })  : _rows = rows,
        _columns = columns {
    _grounds = grounds ?? Array2d<int>(rows, columns, defaultValue: 1);
    _barriers =
        barriers ?? Array2d<Barrier>(rows, columns, defaultValue: Barrier.pass);
    _grid = Array2d(rows, columns, defaultValue: AHexNode.wrong);
    _createGrid(rows: _rows, columns: _columns);
  }

  // void setBarrier(BarrierPoint point) {
  //   assert(point.x <= _rows, "Point can't be bigger than Array2d rows");
  //   assert(point.y <= _columns, "Point can't be bigger than Array2d column");
  //   _barriers[point.x][point.y] = point.barrier;
  // }

  // void setBarriers(List<BarrierPoint> points) {
  //   for (final point in points) {
  //     assert(point.x <= _rows, "Point can't be bigger than Array2d rows");
  //     assert(point.y <= _columns, "Point can't be bigger than Array2d columns");

  //     _barriers[point.x][point.y] = point.barrier;
  //   }
  // }

  // developer.log('GRID CREATED');

  /// dev
  // for (var i = 0; i < _grid.length; i++) {
  //   final StringBuffer _buffer = StringBuffer();
  //   _buffer.writeln("Row: $i\n");
  //   for (var j = 0; j < _grid.length; j++) {
  //     // final n = grid[i][j];
  //     _buffer.writeln("${grid[i][j]}");
  //   }
  //   developer.log(_buffer.toString());
  // }

  /// return full path without Start position
  /// for Point(0,0) to Point(0,3) result will be [Point(0,3),Point(0,2),Point(0,1)]
  /// ```dart
  /// final result = _astar.findPath(start: Point(0,0),end: Point(0,3));
  /// final moveTo = result.removeLast();
  /// final moveNext = result.removeLast();
  /// ```
  Future<List<AHexNode>> findPath({
    void Function(List<Point<int>>)? doneList,
    required Point<int> start,
    required Point<int> end,
  }) async {
    _start = start;
    _end = end;
    _doneList.clear();
    _waitList.clear();

    if (_barriers[_end.x][_end.y].isBlock) {
      return Future.value([]);
    }

    AHexNode startNode = _grid[_start.x][_start.y];

    AHexNode endNode = _grid[_end.x][_end.y];
    if (_isNeighbors(start, end)) {
      return Future.value([endNode]);
    }
    _addNeighbors();
    
    AHexNode? winner = _getWinner(
      startNode,
      endNode,
    );

    List<AHexNode> path = [_grid[_end.x][_end.y]];
    if (winner?.parent != null) {
      AHexNode nodeAux = winner!.parent!;
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
        _grid[x][y] = AHexNode(
          x: x,
          y: y,
          neighbors: [],
          weight: _grounds[x][y].toDouble(),
        );
      }
    }
  }

  // @experimental
  // AHexNode? _findFirstTarget(List<Point<int>> availableTargets) {
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

    AHexNode a = _grid[start.x][start.y];
    final List<AHexNode> total = [a];
    final List<AHexNode> next = [];

    final List<AHexNode> current = [...a.neighbors];
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
        if (c.g <= steps) {
          total.add(c);
          for (var n in c.neighbors) {
            if (total.contains(n)) continue;
            if (n.parent == null) {
              n.parent = c;
              n.g = n.weight + c.g;
            }
            if (!next.contains(n)) next.add(n);
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

  Future<List<DistancePoint>> findTargets(
      {required Point<int> start, required List<Point<int>> targets}) async {
    _addNeighbors();

    AHexNode a = _grid[start.x][start.y];
    final tNodes = targets.map((i) => _grid[i.x][i.y]).toList();
    final List<DistancePoint> foundedTargets = [];
    final List<AHexNode> total = [a];
    final List<AHexNode> next = [];

    final List<AHexNode> current = [...a.neighbors];
    if (current.isEmpty) {
      return Future.value([]);
    }
    for (var element in a.neighbors) {
      element.parent = a;
      element.g = element.weight + 0;
    }
    current.sort((a, b) => a.g.compareTo(b.g));
    while (current.isNotEmpty || tNodes.isNotEmpty) {
      for (var c in current) {
        total.add(c);
        for (var n in c.neighbors) {
          if (total.contains(n)) continue;
          if (n.parent == null) {
            n.parent = c;
            n.g = n.weight + c.g;
            if (tNodes.contains(n)) {
              tNodes.remove(n);
              foundedTargets.add(DistancePoint(n.x, n.y, n.g));
            }
          }
          next.add(n);
        }
      }
      current.clear();
      current.addAll(next);
      current.sort((a, b) => a.g.compareTo(b.g));
      next.clear();
    }
    return Future.value(foundedTargets);
  }

  AHexNode? _getWinner(AHexNode current, AHexNode end) {
    _waitList.clear();
    _doneList.clear();
    AHexNode? winner;
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

  void _analyzeDistance(AHexNode current, AHexNode end,
      {required AHexNode parent}) {
    current.parent = parent;

    /// minimal cost 1.414 diagonal
    current.g = parent.g + current.weight;

    current.h = _distance(current, end) * 1.0;
  }

  /// Calculates the distance between two nodes.
  int _distance(AHexNode from, AHexNode to) {
    if (from.y >= to.y) {
      // 1
      if (from.x >= to.x) {
        return (from.x - to.x).abs() + (from.y - to.y);
      }
      // 2
      if (from.u >= to.u) return from.y - to.y;
      // 3
      return (to.x - from.x).abs();
    }
    // 4
    if (to.x >= from.x) {
      return (from.x - to.x).abs() + (from.y - to.y).abs();
    }
    // 5
    if (to.u < from.u) return (from.x - to.x).abs();
    // 6
    return to.y - from.y;
  }

  bool _isNeighbors(Point<int> a, Point<int> b) {
    final s = (b - a);
    return (s.x.abs() <= 1 && s.y.abs() <= 1);
  }

  /// Adds neighbors to cells
  void _addNeighbors() {
    for (var row in _grid.array) {
      for (AHexNode node in row) {
        node.parent = null;
        node.h = 0.0;
        _chainNeighbors(node);
      }
    }
  }

  void _chainNeighbors(
    AHexNode node,
  ) {
    final x = node.x;
    final y = node.y;

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

    /// adds in top
    if (y > 0) {
      final t = _grid[x][y - 1];
      if (!_barriers[t.x][t.y].isBlock) {
        node.neighbors.add(t);
      }
      if (x < (_grid.length - 1)) {
        final t2 = _grid[x + 1][y - 1];
        if (!_barriers[t2.x][t2.y].isBlock) {
          node.neighbors.add(t2);
        }
      }
    }

    /// adds in bottom
    if (y < (_grid.first.length - 1)) {
      final t = _grid[x][y + 1];
      if (!_barriers[t.x][t.y].isBlock) {
        node.neighbors.add(t);
      }

      if (x > 0) {
        final t2 = _grid[x - 1][y + 1];
        if (!_barriers[t2.x][t2.y].isBlock) {
          node.neighbors.add(t2);
        }
      }
    }

    // /// adds in top-left
    // if (y > 0 && x > 0) {
    //   final t = _grid[x - 1][y - 1];
    //   if (!_barriers[t.x][t.y].isBlock) {
    //     node.neighbors.add(t);
    //   }
    // }

    // /// adds in top-right
    // if (y > 0 && x < (_grid.length - 1)) {
    //   final t = _grid[x + 1][y - 1];
    //   if (!_barriers[t.x][t.y].isBlock) {
    //     node.neighbors.add(t);
    //   }
    // }

    // /// adds in bottom-left
    // if (x > 0 && y < (_grid.first.length - 1)) {
    //   final t = _grid[x - 1][y + 1];
    //   if (!_barriers[t.x][t.y].isBlock) {
    //     node.neighbors.add(t);
    //   }
    // }

    // /// adds in bottom-right
    // if (x < (_grid.length - 1) && y < (_grid.first.length - 1)) {
    //   final t = _grid[x + 1][y + 1];
    //   if (!_barriers[t.x][t.y].isBlock) {
    //     node.neighbors.add(t);
    //   }
    // }
  }

  @visibleForTesting
  Array2d<AHexNode> get grid => _grid;
}
