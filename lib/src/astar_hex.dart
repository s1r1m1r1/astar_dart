import 'package:astar_dart/astar_dart.dart';

class AStarHex extends AstarGrid {
  AStarHex({
    required super.rows,
    required super.columns,
    required GridBuilder super.gridBuilder,
  });

  @override
  List<ANode> findPath({
    void Function(List<Point>)? visited,
    required ({int x, int y}) start,
    required ({int x, int y}) end,
  }) {
    /// If the end node is blocked, return an empty path.

    /// Get the start and end nodes from the grid.
    ANode startNode = grid.elementAt(start.x, start.y);
    ANode endNode = grid.elementAt(end.x, end.y);

    /// If start and end are neighbors, return a direct path.
    if (_isNeighbors(start, end)) return [endNode, startNode];
    if (endNode.isBarrier) return [startNode];

    startNode.g = 0;
    startNode.visited = true;
    ANode? winner = getWinner(startNode, endNode);
    if (winner == null) return [startNode];
    final path = reconstruct(winner);
    visited?.call(grid
        .whereabout((i) => i.visited)
        .map((i) => (x: i.x, y: i.y))
        .toList());

    return path;
  }

  //----------------------------------------------------------------------

  /// Analyzes the distance between two nodes and updates the current node's parent, g, and h values
  @override
  void analyzeDistance(ANode current, ANode end, {required ANode parent}) {
    current.parent = parent;
    current.g = parent.g + current.weight;
    // make short distance stronger by multiply by 2.0
    current.h = _distance(current, end);
  }

  /// Calculates the distance between two nodes.
  /// 6 triangle zone , calculate for each zone correct func
  int _distance(ANode from, ANode to) {
    if (from.y >= to.y) {
      // 1
      if (from.x >= to.x) {
        return (from.x - to.x).abs() + (from.y - to.y);
      }
      // 2
      if ((from.x + from.y) >= (to.x + to.y)) return from.y - to.y;
      // 3
      return (to.x - from.x).abs();
    }
    // 4
    if (to.x >= from.x) {
      return (from.x - to.x).abs() + (from.y - to.y).abs();
    }
    // 5
    if ((to.x + to.y) < (from.x + from.y)) return (from.x - to.x).abs();
    // 6
    return to.y - from.y;
  }

  /// Checks if two points are neighbors on a hexagonal grid.
  bool _isNeighbors(
    ({int x, int y}) a,
    ({int x, int y}) b,
  ) {
    ///      0,-1;  +1 -1
    /// -1,0 ; center ;  +1,0
    ///     -1,+1;  0,+1
    var top = a.y >= b.y ? a : b;
    var bot = a.y >= b.y ? b : a;

    // top
    if ((top.x == bot.x || top.x == bot.x + 1) && top.y == bot.y - 1) {
      return true;
    }
    // middle
    if ((top.x == bot.x + 1 || top.x == bot.x - 1) && top.y == bot.y) {
      return true;
    }
    // bottom
    if ((top.x == bot.x - 1 || top.x == bot.x) && top.y == bot.y + 1) {
      return true;
    }
    return false;
  }

  /// Adds neighbors to each node in the grid.
  @override
  void addNeighbors() {
    final maxY = grid.height - 1;
    final maxX = grid.width - 1;
    for (int i = 0; i < grid.length; i++) {
      final node = grid.array[i];
      if (node.isBarrier) continue;
      node.parent = null;
      node.h = 0;
      node.g = 0;
      node.neighbors = null;
      _chainNeighbors(node, maxX, maxY);
    }
  }

  /// Connects a node to its neighbors on a hexagonal grid.
  void _chainNeighbors(
    ANode node,
    int maxX,
    int maxY,
  ) {
    final x = node.x;
    final y = node.y;

    /// adds in left
    if (x > 0) {
      final t = grid.elementAt(x - 1, y);
      if (!t.isBarrier) {
        node.addNeighbor(t);
      }
    }

    /// adds in right
    if (x < maxY) {
      final t = grid.elementAt(x + 1, y);
      if (!t.isBarrier) {
        node.addNeighbor(t);
      }
    }

    /// adds in top
    if (y > 0) {
      final t = grid.elementAt(x, y - 1);
      if (!t.isBarrier) {
        node.addNeighbor(t);
      }
      if (x < maxX) {
        final t2 = grid.elementAt(x + 1, y - 1);
        if (!t2.isBarrier) {
          node.addNeighbor(t2);
        }
      }
    }

    /// adds in bottom
    if (y < maxY) {
      final t = grid.elementAt(x, y + 1);
      if (!t.isBarrier) {
        node.addNeighbor(t);
      }

      if (x > 0) {
        final t2 = grid.elementAt(x - 1, y + 1);
        if (!t2.isBarrier) {
          node.addNeighbor(t2);
        }
      }
    }
  }
}
