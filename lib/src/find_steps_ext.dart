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
    List<Point<int>> obstacles = const [],
  }) {
    ANode a = grid[start.x][start.y];
    a.visited = true;
    final List<ANode> total = [];
    final List<ANode> next = [];
    final List<ANode> current = [];

    for (var o in obstacles) {
      grid[o.x][o.y].isObstacle = true;
    }
    for (var n in a.neighbors) {
      n.parent = a;
      n.g = n.weight;
      if (!n.isObstacle) {
        current.add(n);
      }
    }
    if (current.isEmpty) {
      return [];
    }
    current.sort();
    for (var i = 0; i < steps; i++) {
      for (var c in current) {
        if (c.g <= steps) {
          c.visited = true;
          total.add(c);
          for (var n in c.neighbors) {
            if (n.visited) continue;
            if (n.isObstacle) continue;
            n.visited = true;
            n.parent = c;
            n.g = n.weight + c.g;
            next.add(n);
          }
        } else {
          next.add(c);
        }
      }

      current.clear();
      current.addAll(next);
      next.clear();
      current.sort();
    }
    return total.map((i) => DistancePoint(i.x, i.y, i.g)).toList();
  }

  List<DistancePoint> findTargets({
    required Point<int> start,
    required List<Point<int>> targets,
    List<Point<int>> obstacles = const [],
    required int steps,
  }) {
    ANode a = grid[start.x][start.y];
    a.visited = true;

    for (var t in targets) {
      grid[t.x][t.y].isTarget = true;
    }

    for (var o in obstacles) {
      grid[o.x][o.y].isObstacle = true;
    }
    // final tNodes = targets.map((i) => grid[i.x][i.y]).toList();
    final founded = <ANode>[];
    final next = <ANode>[];

    final current = List<ANode>.empty(growable: true);

    for (var n in a.neighbors) {
      n.parent = a;
      n.g = n.weight;
      if (!n.isObstacle) {
        current.add(n);
      }
    }
    if (current.isEmpty) {
      return [];
    }
    current.sort();
    for (var i = 0; i < steps; i++) {
      for (var c in current) {
        if (c.isTarget) {
          c.visited = true;
          founded.add(c);
        } else {
          for (var n in c.neighbors) {
            if (n.visited) continue;
            if (n.isObstacle) continue;
            n.visited = true;
            n.parent = c;
            n.g = n.weight + c.g;
            if (n.isTarget) {
              founded.add(n);
              continue;
            }
            next.add(n);
          }
        }
      }

      current.clear();
      current.addAll(next);
      current.sort();
      next.clear();
    }

    return founded.map((i) => DistancePoint(i.x, i.y, i.g)).toList();
  }

  /// find steps area , useful for Turn Based Game
  /// example 3 steps
  /// ```
  ///          3
  ///       3  2  3 [x]
  ///    3  2  1  2  3
  ///   [x]  1 🧍‍♂️ 1  2  3
  ///    3  2  1  2  3
  ///       3  2  3 [x]
  ///          3
  /// ```
  ({List<DistancePoint> steps, List<DistancePoint> targets}) findStepsTargets({
    required int steps,
    required Point<int> start,
    required List<Point<int>> targets,
    List<Point<int>> obstacles = const [],
  }) {
    ANode a = grid[start.x][start.y];
    a.visited = true;
    final List<ANode> total = [];
    final List<ANode> next = [];
    final List<ANode> current = [];
    final List<ANode> founded = [];

    for (var o in obstacles) {
      grid[o.x][o.y].isObstacle = true;
    }
    for (var t in targets) {
      grid[t.x][t.y].isTarget = true;
    }
    for (var n in a.neighbors) {
      n.parent = a;
      n.g = n.weight;
      n.visited = true;
      if (!n.isObstacle) {
        current.add(n);
      }
    }
    if (current.isEmpty) {
      return (steps: [], targets: []);
    }
    current.sort((a, b) => a.f.compareTo(b.f));
    for (var i = 0; i < steps; i++) {
      for (var c in current) {
        if (c.isTarget) {
          c.visited = true;
          founded.add(c);
        } else if (c.g <= steps) {
          total.add(c);
          for (var n in c.neighbors) {
            if (n.visited) continue;
            if (n.isObstacle) {
              n.visited = true;
              continue;
            }
            n.visited = true;
            n.parent = c;
            n.g = n.weight + c.g;
            if (n.isTarget) {
              founded.add(n);
            } else {
              next.add(n);
            }
          }
        } else {
          next.add(c);
        }
      }

      current.clear();
      current.addAll(next);
      next.clear();
      current.sort((a, b) => a.f.compareTo(b.f));
    }
    total.insert(0, a);
    return (
      steps: total.map((i) => DistancePoint(i.x, i.y, i.g)).toList(),
      targets: founded.map((i) => DistancePoint(i.x, i.y, i.g)).toList(),
    );
  }

  // List<DistancePoint> reconstructPath(Point<int> point) {
  //   final path = <DistancePoint>[];
  //   var current = grid[point.x][point.y];
  //   while (current.parent != null) {
  //     path.add(DistancePoint(current.x, current.y, current.g));
  //     current = current.parent!;
  //   }
  //   return path.reversed.toList();
  // }
}
