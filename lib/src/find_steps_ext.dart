import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:astar_dart/src/astar_grid.dart';

extension AstarGridExt on AstarGrid {
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
    addNeighbors();

    ANode a = grid[start.x][start.y];
    final List<ANode> total = [a];
    final List<ANode> next = [];

    final List<ANode> current = [...a.neighbors];
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
    addNeighbors();

    ANode a = grid[start.x][start.y];
    final tNodes = targets.map((i) => grid[i.x][i.y]).toList();
    final List<DistancePoint> foundedTargets = [];
    final List<ANode> total = [a];
    final List<ANode> next = [];

    final List<ANode> current = [...a.neighbors];
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
}
