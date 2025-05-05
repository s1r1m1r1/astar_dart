import 'dart:math';

import '../astar_dart.dart';

class AStarManhattan extends AstarGrid {
  AStarManhattan(
      {required int rows,
      required int columns,
      GridBuilder? gridBuilder,
      required})
      : super(
          gridBuilder: gridBuilder,
          rows: rows,
          columns: columns,
        );

  void setBarrier({required int x, required int y, required Barrier barrier}) {
    assert(x <= rows, "Point can't be bigger than Array2d rows");
    assert(y <= columns, "Point can't be bigger than Array2d column");
    grid[x][y].barrier = barrier;
  }

  void setPoint(WeightedPoint point) {
    assert(point.x <= rows, "Point can't be bigger than Array2d rows");
    assert(point.y <= columns, "Point can't be bigger than Array2d columns");
    grid[point.x][point.y].weight = point.weight.toDouble();
  }

  void setPoints(List<WeightedPoint> points) {
    for (final point in points) {
      assert(point.x <= rows, "Point can't be bigger than Array2d rows");
      assert(point.y <= columns, "Point can't be bigger than Array2d columns");
      grid[point.x][point.y].weight = point.weight.toDouble();
    }
  }

  /// return full path without Start position
  /// for Point(0,0) to Point(0,3) result will be [Point(0,3),Point(0,2),Point(0,1)]
  /// ```dart
  /// final result = _astar.findPath(start: Point(0,0),end: Point(0,3));
  /// final moveTo = result.removeLast();
  /// final moveNext = result.removeLast();
  /// ```
  @override
  List<ANode> findPath({
    void Function(List<Point<int>>)? doneList,
    required ({int x, int y}) start,
    required ({int x, int y}) end,
  }) {
    this.doneList.clear();
    waitList.clear();

    if (grid[end.x][end.y].barrier == Barrier.block) {
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

    while (waitList.isNotEmpty) {
      final c = waitList.removeLast();
      if (end == c) return c;
      for (var n in c.neighbors) {
        if (n.parent == null) {
          _checkDistance(n, end, parent: c);
        }
        if (!doneList.contains(n)) {
          waitList.add(n);
          doneList.add(c);
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
    // performance , make direction more stronger
    current.h = _distance(current, end) * 2.0;
  }

  int _distance(ANode a, ANode b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs();
  }

  bool _isNeighbors(
    ({int x, int y}) start,
    ({int x, int y}) end,
  ) {
    int dx = (start.x - end.x).abs();
    int dy = (start.y - end.y).abs();

    // Manhattan
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
  }

  /// expensive not call every time,try reusing
  @override
  void addNeighbors() {
    final maxX = grid.length - 1;
    final maxY = grid.first.length - 1;
    for (var x = 0; x < grid.length; x++) {
      final row = grid[x];
      for (var y = 0; y < row.length; y++) {
        final node = row[y];
        node.parent = null;
        // improve performance x times
        node.h = 0.0;
        node.g = 0.0;
        node.neighbors.clear();
        _chainNeighborsManhattan(node, maxX: maxX, maxY: maxY);
      }
    }
  }

  void _chainNeighborsManhattan(ANode node,
      {required int maxX, required int maxY}) {
    final x = node.x;
    final y = node.y;
    // Optimized neighbor adding for Manhattan distance (only cardinal directions)
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
  }
}
