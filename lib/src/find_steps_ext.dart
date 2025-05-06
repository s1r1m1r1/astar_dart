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
  List<DistancePoint> findSteps(
      {required int steps, required Point<int> start}) {
    ANode a = grid[start.x][start.y];
    final List<ANode> total = [a];
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
          total.add(c);
          for (var n in c.neighbors) {
            if (total.contains(n)) continue;
            if (n.parent == null) {
              n.parent = c;
              n.g = n.weight + c.g;
            }
            if (!next.contains(n)) {
              next.add(n);
            }
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
    ANode a = grid[start.x][start.y];
    final tNodes = targets.map((i) => grid[i.x][i.y]).toList();
    final List<ANode> founded = [];
    final List<ANode> total = [a];
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
      if (tNodes.isEmpty) break;
      for (var c in current) {
        total.add(c);
        for (var n in c.neighbors) {
          if (total.contains(n)) continue;
          if (n.parent == null) {
            n.parent = c;
            n.g = n.weight + c.g;
            if (tNodes.contains(n)) {
              tNodes.remove(n);
              founded.add(n);
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
    return founded.map((i) => DistancePoint(i.x, i.y, i.g)).toList();
  }
}
