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
  final List<ANode> doneList = [];

  /// List of nodes that are waiting to be evaluated.
  final List<ANode> waitList = [];

  /// Finds a path between the start and end points.
  ///
  /// [doneList] An optional callback to track the nodes explored during pathfinding.
  /// [start] The starting point for the path.
  /// [end] The ending point for the path.
  /// Returns a [FutureOr] containing a list of [ANode] representing the path.
  List<ANode> findPath({
    void Function(List<Point<int>>)? doneList,
    required ({int x, int y}) start,
    required ({int x, int y}) end,
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
    if (end == current) return current;
    for (var n in current.neighbors) {
      if (n.parent == null) {
        analyzeDistance(n, end, parent: current);
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
          analyzeDistance(n, end, parent: c);
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

  /// calculate distance follow Grid rules
  @internal
  void analyzeDistance(
    ANode current,
    ANode end, {
    required ANode parent,
  });

  //clear if it needed, without reconect if it needed , for  performance
  void resetNodes() {
    for (var x = 0; x < grid.length; x++) {
      final row = grid[x];
      for (var node in row) {
        node.reset();
      }
    }
  }
}
