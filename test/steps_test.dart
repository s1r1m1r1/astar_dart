import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:test/test.dart';

void main() {
  late final AStarManhattan astar;
  setUpAll(() {
    astar = AStarManhattan(rows: 7, columns: 7);
    astar.setBarrier(
      x: 2,
      y: 0,
      isBarrier: true,
    );
    astar.addNeighbors();
  });

  group('test steps', () {
    test('test top-left 2 steps with one barrier', () {
      astar.resetNodes();
      final path = astar.findSteps(start: const Point(0, 0), steps: 2);
      // with barrier 2,0
      expect(path.length, 4); // Check number of cols
    });

    /// (0,0)  (0,1)  (0,2)  (0,3)  (0,4)  (0,5)  (0,6)
    /// start    1      2      3      -      -      -
    ///
    /// (1,0)  (1,1)  (1,2)  (1,3)  (1,4)  (1,5)  (1,6)
    ///   1      2      3      -      -      -      -
    ///
    /// (2,0)  (2,1)  (2,2)  (2,3)  (2,4)  (2,5)  (2,6)
    ///   x      3      -      -      -      -     -
    ///
    /// (3,0)  (3,1)  (3,2)  (3,3)  (3,4)  (3,5)  (3,6)
    ///   -      -      -      -      -      -      -
    ///
    /// (4,0)  (4,1)  (4,2)  (4,3)  (4,4)  (4,5)  (4,6)
    ///   -      -      -      -      -      -      -
    ///
    /// (5,0)  (5,1)  (5,2)  (5,3)  (5,4)  (5,5)  (5,6)
    ///   -      -      -      -      -      -      -
    ///
    /// (6,0)  (6,1)  (6,2)  (6,3)  (6,4)  (6,5)  (6,6)
    ///   -      -      -      -      -      -      -
    ///

    test('test top-left 3 steps with one barrier', () {
      astar.resetNodes();
      final path = astar.findSteps(start: const Point(0, 0), steps: 3);
      // with barrier 2,0
      expect(path.length, 7); // Check number of cols
    });

    test('test bottom-right 3 steps', () {
      astar.resetNodes();
      final path = astar.findSteps(start: const Point(6, 6), steps: 3);
      expect(path.length, 9); // Check number of cols
    });

    test('test center 2 steps', () {
      astar.resetNodes();
      final path = (astar.findSteps(start: const Point(3, 3), steps: 2));
      expect(path.length, 12); // Check number of cols
    });
    test('test center 3 steps', () {
      astar.resetNodes();
      final path = (astar.findSteps(start: const Point(3, 3), steps: 3));
      expect(path.length, 24); // Check number of cols
    });

    /// (y,x)
    /// (0,0)  (0,1)  (0,2)  (0,3)  (0,4)  (0,5)  (0,6)
    ///   -      -      4      3      4      -      -
    ///
    /// (1,0)  (1,1)  (1,2)  (1,3)  (1,4)  (1,5)  (1,6)
    ///   -      4      3      2      3      4      -
    ///
    /// (2,0)  (2,1)  (2,2)  (2,3)  (2,4)  (2,5)  (2,6)
    ///  xx      3      x      1      x      -      -
    ///
    /// (3,0)  (3,1)  (3,2)  (3,3)  (3,4)  (3,5)  (3,6)
    ///   3      2      1    start    1      x      -
    ///
    /// (4,0)  (4,1)  (4,2)  (4,3)  (4,4)  (4,5)  (4,6)
    ///   4      3      2      1      2      x      -
    ///
    /// (5,0)  (5,1)  (5,2)  (5,3)  (5,4)  (5,5)  (5,6)
    ///   -      4      x      2      3      4      -
    ///
    /// (6,0)  (6,1)  (6,2)  (6,3)  (6,4)  (6,5)  (6,6)
    ///   -      -      4      3      4      -      -
    ///
    test('bloc path 2', () {
      astar.resetNodes();
      final path = astar.findSteps(
          start: const Point(3, 3),
          steps: 4,
          obstacles: [
            Point(2, 2),
            Point(2, 4),
            Point(5, 2),
            Point(3, 5),
            Point(4, 5)
          ]);
      expect(path.length, 26); // Check count
    });

    /// (0,0)  (0,1)  (0,2)  (0,3)  (0,4)  (0,5)  (0,6)
    ///   2      1      4      3      4      -      -
    ///
    /// (1,0)  (1,1)  (1,2)  (1,3)  (1,4)  (1,5)  (1,6)
    ///   1    start    1      2      x      -      -
    ///
    /// (2,0)  (2,1)  (2,2)  (2,3)  (2,4)  (2,5)  (2,6)
    ///  xx      1      x      3      x      -      -
    ///
    /// (3,0)  (3,1)  (3,2)  (3,3)  (3,4)  (3,5)  (3,6)
    ///   3      2      3      4      -      -      -
    ///
    /// (4,0)  (4,1)  (4,2)  (4,3)  (4,4)  (4,5)  (4,6)
    ///   4      3      4      -      -      -      -
    ///
    /// (5,0)  (5,1)  (5,2)  (5,3)  (5,4)  (5,5)  (5,6)
    ///   -      4      -      -      -      -      -
    ///
    /// (6,0)  (6,1)  (6,2)  (6,3)  (6,4)  (6,5)  (6,6)
    ///   -      -      -      -      -      -      -
    ///
    test('bloc path 3', () {
      astar.resetNodes();
      final path =
          astar.findSteps(start: const Point(1, 1), steps: 4, obstacles: [
        Point(2, 2),
        Point(1, 4),
        Point(2, 4),
        Point(3, 5),
      ]);
      expect(path.length, 18); // Check count
    });
    //----------------
  });
}
