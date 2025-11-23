import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:test/test.dart';

void main() {
  group('test AStarSquareGrid euclidean', () {
    late AStarEuclidean astar;

    setUp(() {
      // Create a NEW instance for EACH test in this group.
      // This ensures each test has a clean state.
      astar = AStarEuclidean(
          rows: 4,
          columns: 4,
          gridBuilder: (int x, int y) {
            return ANode(
              x: x,
              y: y,
              neighbors: [],
            );
          });
      astar.addNeighbors();
    });

    tearDown(() {
      // Clean up the instance used by this group.
      astar.resetNodes(resetBarrier: true);
    });

    test('test first point is end point', () {
      final path =
          astar.findPath(start: const (x: 0, y: 0), end: const (x: 0, y: 3));
      expect(path.length, 4);
      expect(path.last.x, 0);
      expect(path.last.y, 0);
      expect(path.first.x, 0);
      expect(path.first.y, 3);
    });
  });

  // Similarly, for other groups...
  group('test AStarSquareGrid euclidean 2', () {
    late AStarEuclidean astar;

    setUp(() {
      astar = AStarEuclidean(
          rows: 4,
          columns: 4,
          gridBuilder: (int x, int y) {
            return ANode(
              x: x,
              y: y,
              neighbors: [],
            );
          });
      astar.addNeighbors();
    });

    tearDown(() {
      astar.resetNodes(resetBarrier: true);
    });

    test('test last point is start ', () {
      final path =
          astar.findPath(start: const (x: 0, y: 0), end: const (x: 3, y: 3));
      expect(path.length, 4);
      expect(path.last.x, 0);
      expect(path.last.y, 0);
      expect(path.first.x, 3);
      expect(path.first.y, 3);
    });
  });

  // You should apply this pattern to all your groups.
}
