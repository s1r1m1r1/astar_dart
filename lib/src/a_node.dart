import 'dart:math';

/// Represents a node in the A* search grid.
class ANode extends Point<int> implements Comparable<ANode> {
  /// The parent node in the path.
  ANode? parent;
  final List<ANode> neighbors;

  /// The barrier status of the node (e.g., passable, blocked)
  bool isBarrier;

  // alternative marker to mark the node as visited
  bool visited = false;

  bool isTarget = false;
  bool isObstacle = false;

  /// The weight or cost of moving to this node.
  int weight;

  /// The actual cost of the path from the start node to this node (g-score).
  int g = 0;

  /// The estimated cost of the path from this node to the end node (h-score).
  int h = 0;

  /// The total estimated cost of the path from the start node to the end node through this node (f-score = g + h).
  int get f => g + h;

  /// Creates a new ANode.
  ANode({
    required int x,
    required int y,
    required this.neighbors,
    this.isBarrier = false,
    this.parent,
    this.weight = 1,
  }) : super(x, y);

  /// Compares this node to another node based on their x and y coordinates.
  @override
  bool operator ==(covariant ANode other) {
    return other.x == x && other.y == y;
  }

  /// Generates a hash code for this node based on its x, y coordinates, and runtime type.
  @override
  int get hashCode {
    return Object.hashAll([x, y, runtimeType]);
  }

  /// Compares this node to another node for sorting purposes.
  ///
  /// Nodes are compared primarily by their f-scores. If f-scores are equal,
  /// they are compared by their h-scores as a tie-breaker.
  @override
  int compareTo(ANode other) {
    int result = f.compareTo(other.f); // Compare f values first
    if (result == 0) {
      // Tie-breaker using h if f values are equal
      result = h.compareTo(other.h);
    }
    return result;
  }

  /// reset [ANode] , but save [neighbors] and [barrier]
  void reset() {
    parent = null;
    h = 0;
    g = 0;
  }
}
