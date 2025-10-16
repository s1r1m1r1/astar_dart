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
      final path = astar.findPath(start: Point(0, 0), end: Point(0, 3));
      expect(path.length, 4);
      expect(path.last, const Point(0, 0));
      expect(path.first, const Point(0, 3));
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
      final path = astar.findPath(start: Point(0, 0), end: Point(3, 3));
      expect(path.length, 4);
      expect(path.last, Point(0, 0));
      expect(path.first, Point(3, 3));
    });
  });

  // You should apply this pattern to all your groups.
}
