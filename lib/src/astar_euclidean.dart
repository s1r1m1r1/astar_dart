import 'package:astar_dart/astar_dart.dart';

class AStarEuclidean extends AstarGrid {
  AStarEuclidean({
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
    ANode startNode = grid.elementAt(start.x, start.y);
    ANode endNode = grid.elementAt(end.x, end.y);

    if (endNode.isBarrier) return [startNode];
    if (_isNeighbors(start, end)) return [endNode, startNode];

    startNode.visited = true;
    startNode.g = 0;
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

  @override
  void analyzeDistance(ANode current, ANode end, {required ANode parent}) {
    current.parent = parent;
    current.g = parent.g + current.weight;
    current.h = _distance(current, end) * 2;
  }

  int _distance(ANode a, ANode b) {
    int toX = a.x - b.x;
    int toY = a.y - b.y;
    return toX.abs() + toY.abs();
  }

  bool _isNeighbors(
    ({int x, int y}) start,
    ({int x, int y}) end,
  ) {
    int dx = (start.x - end.x).abs();
    int dy = (start.y - end.y).abs();

    return dx <= 1 && dy <= 1;
  }

  /// Adds neighbors to cells
  @override
  void addNeighbors() {
    final maxX = grid.width - 1;
    final maxY = grid.height - 1;
    for (int i = 0; i < grid.length; i++) {
      final node = grid.array[i];
      if (node.isBarrier) continue;
      node.parent = null;
      node.h = 0;
      node.g = 0;
      node.neighbors = null;
      _chainNeighbors(node, maxX: maxX, maxY: maxY);
    }
  }

  void _chainNeighbors(ANode node, {required int maxX, required int maxY}) {
    final x = node.x;
    final y = node.y;
    if (y > 0) {
      // Top
      final neighbor = grid.elementAt(x, y - 1);
      if (!neighbor.isBarrier) {
        node.addNeighbor(neighbor);
      }
    }
    if (y < maxY) {
      // Bottom
      final neighbor = grid.elementAt(x, y + 1);
      if (!neighbor.isBarrier) {
        node.addNeighbor(neighbor);
      }
    }

    if (x > 0) {
      // Left
      final neighbor = grid.elementAt(x - 1, y);
      if (!neighbor.isBarrier) {
        node.addNeighbor(neighbor);
      }
    }
    if (x < maxX) {
      // Right
      final neighbor = grid.elementAt(x + 1, y);
      if (!neighbor.isBarrier) {
        node.addNeighbor(neighbor);
      }
    }

    // Diagonals
    if (x > 0 && y > 0) {
      // Top-Left
      final neighbor = grid.elementAt(x - 1, y - 1);
      if (!neighbor.isBarrier) {
        node.addNeighbor(neighbor);
      }
    }
    if (x > 0 && y < maxY) {
      // Bottom-Left
      final neighbor = grid.elementAt(x - 1, y + 1);
      if (!neighbor.isBarrier) {
        node.addNeighbor(neighbor);
      }
    }
    if (x < maxX && y > 0) {
      // Top-Right
      final neighbor = grid.elementAt(x + 1, y - 1);
      if (!neighbor.isBarrier) {
        node.addNeighbor(neighbor);
      }
    }

    if (x < maxX && y < maxY) {
      // Bottom-Right
      final neighbor = grid.elementAt(x + 1, y + 1);
      if (!neighbor.isBarrier) {
        node.addNeighbor(neighbor);
      }
    }
  }
}
