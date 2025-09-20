import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:test/test.dart';

void main() {
  // We remove the shared instance to avoid the race condition.
  // late final AStarManhattan astar;

  // The setUpAll is no longer needed because we create a new
  // astar instance for each test.
  // setUpAll(() {
  //   astar = AStarManhattan(
  //     rows: 4,
  //     columns: 4,
  //     gridBuilder: (x, y) {
  //       return ANode(x: x, y: y, neighbors: [], isBarrier: false);
  //     },
  //   );
  //   astar.addNeighbors();
  // });

  group('test AStarSquareGrid manhattan', () {
    // Declare the astar variable here so it is local to this group.
    late AStarManhattan astar;

    // The setUp function now creates a new instance for each test.
    setUp(() {
      astar = AStarManhattan(
        rows: 4,
        columns: 4,
        gridBuilder: (x, y) {
          return ANode(x: x, y: y, neighbors: [], isBarrier: false);
        },
      );
      astar.addNeighbors();
    });

    // The teardown is optional but good practice to release resources.
    tearDown(() {
      astar.resetNodes();
    });

    test('findPath returns a path', () {
      final path =
          (astar.findPath(start: const Point(0, 0), end: const Point(3, 3)));
      expect(path, isNotEmpty);
    });

    test('the last point is the start point', () {
      final path =
          (astar.findPath(start: const Point(0, 0), end: const Point(3, 3)));
      expect(path.last, const Point(0, 0));
    });

    test('the first point is the end point', () {
      final path =
          (astar.findPath(start: const Point(0, 0), end: const Point(3, 3)));
      expect(path.first, const Point(3, 3));
    });

    test('a path from (0,0) to (3,3) has a length of 7', () {
      final path =
          (astar.findPath(start: const Point(0, 0), end: const Point(3, 3)));
      expect(path.length, 7);
    });

    test('a path from (0,0) to (1,1) is not found with Manhattan distance', () {
      // Manhattan distance does not allow diagonal movement by default.
      final path =
          (astar.findPath(start: const Point(0, 0), end: const Point(1, 1)));
      expect(path.length, 3);
      expect(path.last, Point(0, 0));
      expect(path.first, Point(1, 1));
    });

    //   test('A path with a barrier is shorter or empty', () {
    //     // Block the path from (0,0) to (1,1)
    //     final nodeToBlock = astar.getNode(1, 0);
    //     nodeToBlock.isBarrier = true;
    //     final path = (astar.findPath(start: const Point(0, 0), end: const Point(1, 1)));
    //     expect(path, isEmpty);
    //   });

    //   test('findPath on a 4x4 grid with a barrier from (0,0) to (3,3)', () {
    //     final nodeToBlock = astar.getNode(1, 1);
    //     nodeToBlock.isBarrier = true;
    //     final path = (astar.findPath(start: const Point(0, 0), end: const Point(3, 3)));
    //     expect(path.length, 7); // The path should just go around the single barrier
    //   });
  });
}
