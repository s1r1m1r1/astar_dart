import 'dart:math';

import 'package:astar_dart/astar_dart.dart';

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
  List<DistancePoint> findSteps({
    required int steps,
    required Point<int> start,
  }) {
    ANode a = grid[start.x][start.y];
    a.visited = true;
    final List<ANode> total = [];
    final List<ANode> next = [];

    final List<ANode> current = [...a.neighbors];
    if (current.isEmpty) {
      return [];
    }
    for (var element in a.neighbors) {
      element.parent = a;
      element.g = element.weight;
    }
    current.sort((a, b) => a.g.compareTo(b.g));
    for (var i = 0; i < steps; i++) {
      for (var c in current) {
        if (c.g <= steps) {
          c.visited = true;
          total.add(c);
          for (var n in c.neighbors) {
            if (n.visited) continue;
            n.visited = true;
            n.parent = c;
            n.g = n.weight + c.g;
            next.add(n);
          }
        }
      }

      current.clear();
      current.addAll(next);
      next.clear();
      current.sort((a, b) => a.g.compareTo(b.g));
    }

    return total
        .map((i) => DistancePoint(i.x, i.y, i.weight.toDouble()))
        .toList();
  }

  List<DistancePoint> findTargets({
    required Point<int> start,
    required List<Point<int>> targets,
    required int maxSteps,
  }) {
    final targetCount = targets.length;
    ANode a = grid[start.x][start.y];

    for (var t in targets) {
      grid[t.x][t.y].isTarget = true;
    }
    // final tNodes = targets.map((i) => grid[i.x][i.y]).toList();
    final List<ANode> founded = [];
    final List<ANode> next = [];

    final List<ANode> current = [...a.neighbors];
    if (current.isEmpty) {
      return [];
    }
    for (var element in a.neighbors) {
      element.parent = a;
      element.g = element.weight + 0;
    }
    current.sort((a, b) => a.g.compareTo(b.g));
    for (var i = 0; i < maxSteps; i++) {
      if (founded.length == targetCount) break;
      for (var c in current) {
        for (var n in c.neighbors) {
          if (n.visited) continue;
          n.visited = true;
          n.parent = c;
          n.g = n.weight + c.g;
          if (n.isTarget) {
            if (!founded.contains(n)) {
              founded.add(n);
            }
          } else {
            next.add(n);
          }
        }
      }
      current.clear();
      current.addAll(next);
      current.sort((a, b) => a.g.compareTo(b.g));
      next.clear();
    }
    return founded.map((i) => DistancePoint(i.x, i.y, i.g)).toList();
  }
}
