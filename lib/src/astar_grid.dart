import 'dart:async';
import 'dart:math';

import '../astar_dart.dart';

typedef GridBuilder = ANode Function(int x, int y);

/// /// Abstract base class for A* grid implementations.
/// This class defines the common interface and properties for grids used in A* pathfinding.
abstract class AstarGrid {
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

  /// Adds neighbors to each node in the grid.  This method must be implemented by subclasses to define the grid's connectivity.
  addNeighbors();
}
