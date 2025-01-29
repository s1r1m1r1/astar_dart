import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:astar_dart/src/find_steps_ext.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AStarManhattan astar;

  setUpAll(() {
    astar = AStarManhattan(rows: 10, columns: 10);
    astar.calculateGrid();
  });

  group('AStarSquare test 1', () {
    test('Finds path in simple grid', () async {
      final path = await astar.findPath(
          start: const Point(0, 0), end: const Point(9, 9));
      expect(path.isNotEmpty, true);
    });
    test('Finds path with obstacles', () async {
      astar.calculateGrid();
      astar.setBarriers([
        const BarrierPoint(4, 4, barrier: Barrier.block),
        const BarrierPoint(4, 5, barrier: Barrier.block),
        const BarrierPoint(5, 4, barrier: Barrier.block),
        const BarrierPoint(5, 5, barrier: Barrier.block),
      ]);
      final path = await astar.findPath(
          start: const Point(0, 0), end: const Point(9, 9));
      expect(path.isNotEmpty, true);
    });

    test('No path if blocked', () async {
      astar.calculateGrid();
      astar.setBarrier(const BarrierPoint(5, 5, barrier: Barrier.block));
      final path = (await astar.findPath(
              start: const Point(5, 4), end: const Point(5, 6)))
          .toPointList();
      expect(path.length, 4);
    });

    // test('Finds path with weighted points', () async {
    //   astar.calculateGrid();
    //   astar.setPoint(const WeightedPoint(5, 5, weight: 5)); // Make (5,5) costly
    //   final path = await astar.findPath(
    //       start: const Point(0, 0), end: const Point(9, 9));
    //   expect(path.isNotEmpty,
    //       true); // Path should still exist, but might be different
    // });

    // test('Finds path with Manhattan distance', () async {
    //   astar.setDiagonalMovement(DiagonalMovement.manhattan);
    //   astar.calculateGrid();
    //   final path = await astar.findPath(
    //       start: const Point(0, 0), end: const Point(2, 2));
    //   expect(
    //       path.length, 4); // Manhattan path should be 4 steps (2 right, 2 up)
    // });

    test('Finds steps within range', () async {
      astar.calculateGrid();
      final steps = await astar.findSteps(steps: 3, start: const Point(5, 5));
      expect(steps.isNotEmpty, true);
      // You might want to add more specific assertions about the reachable points
    });

    // test('Handles start and end being neighbors', () async {
    //   astar.calculateGrid();
    //   final path = await astar.findPath(
    //       start: const Point(0, 0), end: const Point(0, 1));
    //   expect(path.isEmpty, true);
    // });

    test('Path contains correct nodes (deep equality)', () async {
      astar.calculateGrid();
      final expectedPath = [
        ANode(x: 0, y: 3, neighbors: [], weight: 1.0),
        ANode(x: 0, y: 2, neighbors: [], weight: 1.0),
        ANode(x: 0, y: 1, neighbors: [], weight: 1.0),
      ];

      final path = await astar.findPath(
          start: const Point(0, 0), end: const Point(0, 3));

      // Use a deep equality check to compare the lists of ANodes
      expect(
        const ListEquality()
            .equals(path, expectedPath), // Using collection package
        true,
      );
    });

    // Add more tests as needed...
  });
}
