import 'dart:async';
import 'dart:math';

import 'package:meta/meta.dart';

import '../astar_dart.dart';

/// Typedef for a function that builds [ANode] given its coordinates.
/// add barriers or others  options like custom neighbors
/// that may be used to create a custom grid
typedef GridBuilder = ANode Function(int x, int y);

/// /// Abstract base class for A* grid implementations.
/// This class defines the common interface and properties for grids used in A* pathfinding.
abstract class AstarGrid {
  /// Constructor for the AstarGrid.
  ///
  /// [gridBuilder] An optional function to customize node creation.
  /// [rows] The number of rows in the grid.
  /// [columns] The number of columns in the grid.
  AstarGrid({
    this.gridBuilder,
    required this.rows,
    required this.columns,
  }) {
    grid = Array2d(
      rows,
      columns,
      valueBuilder: gridBuilder ??
          (x, y) => ANode(
                x: x,
                y: y,
                neighbors: [],
              ),
    );
  }

  /// List of nodes that have been evaluated.
  // final List<ANode> doneList = [];

  /// List of nodes that are waiting to be evaluated.

  /// Finds a path between the start and end points.
  ///
  /// [doneList] An optional callback to track the nodes explored during pathfinding.
  /// [start] The starting point for the path.
  /// [end] The ending point for the path.
  /// Returns a [FutureOr] containing a list of [ANode] representing the path.
  List<ANode> findPath({
    void Function(List<Point<int>>)? visited,
    required Point<int> start,
    required Point<int> end,
  });

  /// Number of rows in the grid.
  late final int rows;

  /// Number of columns in the grid.
  late final int columns;

  /// 2D array representing the grid of nodes.
  late final Array2d<ANode> grid;

  /// A function that builds a node for a given x,y position.  If null, uses a default ANode constructor
  final GridBuilder? gridBuilder;

  /// Adds neighbors to each node in the grid.  This method must be implemented by subclasses to define the grid's connectivity.
  addNeighbors();

  /// Internal function to find the best path using the A* algorithm.
  ///
  /// return [current] if path 1 ceil
  ///
  /// return [end] if path completed
  ///
  /// return null if path not found, no way on labyrinth
  @internal
  ANode? getWinner(ANode current, ANode end) {
    final waitList = <ANode>[];
    if (end == current) return current;
    final neighbors = current.neighbors;
    for (var n in neighbors) {
      n.visited = true;
      n.g = n.weight;
      waitList.add(n);
    }

    waitList.sort((a, b) => b.f.compareTo(a.f));
    // var tail = <ANode>[];
    while (waitList.isNotEmpty) {
      final c = waitList.removeLast();
      if (end == c) return c;
      for (var n in c.neighbors) {
        if (n.visited) continue;
        analyzeDistance(n, end, parent: c);
        n.visited = true;
        waitList.add(n);
      }
      waitList.sort((a, b) => b.f.compareTo(a.f));
    }
    return null;
  }

  List<ANode> reconstruct(Point<int> end) {
    ANode astar = grid[end.x][end.y];
    final parent = astar.parent;
    final path = [astar];
    if (parent == null) return path;
    ANode nextNode = parent;
    path.add(nextNode);
    while (nextNode.parent != null) {
      nextNode = nextNode.parent!;
      path.add(nextNode);
    }

    return path;
  }

  List<ANode> reconstructNormalized(Point<int> end) {
    ANode astar = grid[end.x][end.y];
    final path = [astar];
    final nextList = <ANode>[];
    nextList.addAll(astar.neighbors);
    if (nextList.isEmpty) return path;
    nextList.sort((a, b) => b.g.compareTo(a.g));
    int g = astar.g;

    while (nextList.isNotEmpty) {
      final n = nextList.removeLast();
      if (!n.visited) continue;
      if (n.g < g) {
        g = n.g;
        path.add(n);
        nextList.clear();
        nextList.addAll(n.neighbors);
        nextList.sort((a, b) => b.g.compareTo(a.g));
      }
    }
    return path;
  }

  /// calculate distance follow Grid rules
  @internal
  void analyzeDistance(
    ANode current,
    ANode end, {
    required ANode parent,
  });

  void setBarrier({required int x, required int y, required bool isBarrier}) {
    assert(x <= rows, "Point can't be bigger than Array2d rows");
    assert(y <= columns, "Point can't be bigger than Array2d column");
    grid[x][y].isBarrier = isBarrier;
  }

  void setPoint(WeightedPoint point) {
    assert(point.x <= rows, "Point can't be bigger than Array2d rows");
    assert(point.y <= columns, "Point can't be bigger than Array2d columns");
    grid[point.x][point.y].weight = point.weight;
  }

  /// resetBarrier = ```true```, should connect grid with [addNeighbors] before [findPath]
  ///
  ///
  ///  resetBarrier = ```false```, can reused directly to [findPath]
  void resetNodes({resetBarrier = false}) {
    for (var row in grid.array) {
      for (var node in row) {
        node.parent = null;
        node.h = 0;
        node.g = 0;
        node.visited = false;
        node.isTarget = false;
        node.isObstacle = false;
        if (resetBarrier) {
          node.isBarrier = false;
          node.neighbors.clear();
        }
      }
    }
  }
}
