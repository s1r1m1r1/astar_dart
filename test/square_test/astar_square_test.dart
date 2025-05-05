import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:astar_dart/src/find_steps_ext.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AStarManhattan astar;

  setUpAll(() {
    astar = AStarManhattan(rows: 10, columns: 10);
    // astar.calculateGrid();
  });

  group('AStarSquare test 1', () {
    test('Finds path in simple grid', () {
      astar.addNeighbors();
      final path = astar.findPath(start: (x: 0, y: 0), end: (x: 9, y: 9));
      expect(path.isNotEmpty, true);
    });
    test('Finds path with obstacles', () {
      // astar.calculateGrid();
      astar
        ..setBarrier(x: 4, y: 4, barrier: Barrier.block)
        ..setBarrier(x: 4, y: 5, barrier: Barrier.block)
        ..setBarrier(x: 5, y: 4, barrier: Barrier.block)
        ..setBarrier(x: 5, y: 5, barrier: Barrier.block);

      astar.addNeighbors();
      final path = astar.findPath(start: (x: 0, y: 0), end: (x: 9, y: 9));
      expect(path.isNotEmpty, true);
    });

    test('No path if blocked', () {
      // astar.calculateGrid();
      astar.setBarrier(x: 5, y: 5, barrier: Barrier.block);

      astar.addNeighbors();
      final path = (astar.findPath(start: (x: 5, y: 4), end: (x: 5, y: 6)))
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

    test('Finds steps within range', () {
      // astar.calculateGrid();

      astar.resetNodes();
      final steps = astar.findSteps(steps: 3, start: const Point(5, 5));
      expect(steps.isNotEmpty, true);
      // You might want to add more specific assertions about the reachable points
    });

    // test('Handles start and end being neighbors', () async {
    //   astar.calculateGrid();
    //   final path = await astar.findPath(
    //       start: const Point(0, 0), end: const Point(0, 1));
    //   expect(path.isEmpty, true);
    // });

    test('Path contains correct nodes (deep equality)', () {
      // astar.calculateGrid();
      final expectedPath = [
        ANode(x: 0, y: 3, neighbors: [], weight: 1.0),
        ANode(x: 0, y: 2, neighbors: [], weight: 1.0),
        ANode(x: 0, y: 1, neighbors: [], weight: 1.0),
      ];

      astar.addNeighbors();
      final path = astar.findPath(start: (x: 0, y: 0), end: (x: 0, y: 3));

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
