import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:test/test.dart';

void main() {
  late final AStarManhattan astar;
  setUpAll(() {
    astar = AStarManhattan(rows: 5, columns: 5);
    astar.setBarrier(
      x: 0,
      y: 2,
      isBarrier: true,
    );
    astar.addNeighbors();
  });
  group('find targets', () {
    test('test not targets , no path', () {
      astar.resetNodes();
      final targets = astar.findTargets(
          start: const Point(0, 0),
          targets: [Point(3, 0), Point(3, 1), Point(3, 2), Point(4, 0)],
          steps: 3);

      expect(targets.length, 2); // Check number of cols
    });

    ///
    /// (0,0)  (1,0)  (2,0)  (3,0)  (4,0)
    /// start    1      2      3    [ t ]
    ///
    /// (0,1)  (1,1)  (2,1)  (3,1)  (4,1)
    /// [ t ]    2     [t]     ---    ---
    ///
    /// (0,2)  (1,2)  (2,2)  (3,2)  (4,2)
    ///  xx      3     [ t ]   ---    --
    ///
    /// (0,3)  (1,3)  (2,3)  (3,3)  (4,3)
    ///  ---   [ t ]   -t-    -t-   ---
    ///
    /// (0,4)  (1,4)  (2,4)  (3,4)  (4,4)
    ///  ---    ---    ---    ---    ---
    ///
    ///
    test('test 2  ', () {
      astar.resetNodes();
      final s = astar.findTargets(
          start: const Point(0, 0),
          targets: [
            // found
            Point(0, 1),
            Point(2, 1),
            Point(1, 3),
            Point(2, 2),
            Point(4, 0),
            // not found
            Point(2, 3),
            Point(3, 3),
          ],
          steps: 3);
      expect(s.length, 5);
      expect(s.where((i) => i.distance == 1 && i.x == 0 && i.y == 1).length, 1);
      expect(s.where((i) => i.distance == 4 && i.x == 4 && i.y == 0).length, 1);
    });

    ///
    /// (0,0)  (1,0)  (2,0)  (3,0)  (4,0)
    /// start    1      2      3    [ t ]
    ///
    /// (0,1)  (1,1)  (2,1)  (3,1)  (4,1)
    /// [ t ]    2     [t]     ---    ---
    ///
    /// (0,2)  (1,2)  (2,2)  (3,2)  (4,2)
    ///  xx      3     [ t ]   ---    --
    ///
    /// (0,3)  (1,3)  (2,3)  (3,3)  (4,3)
    ///  ---   [ t ]   -t-    -t-   ---
    ///
    /// (0,4)  (1,4)  (2,4)  (3,4)  (4,4)
    ///  ---    ---    ---    ---    ---
    ///
    ///
    test('test 2  ', () {
      astar.resetNodes();
      final s = astar.findTargets(
          start: const Point(0, 0),
          targets: [
            // found
            Point(0, 1),
            Point(2, 1),
            Point(1, 3),
            Point(2, 2),
            Point(4, 0),
            // not found
            Point(2, 3),
            Point(3, 3),
          ],
          steps: 3);
      expect(s.length, 5);
      expect(s.where((i) => i.distance == 1 && i.x == 0 && i.y == 1).length, 1);
      expect(s.where((i) => i.distance == 4 && i.x == 4 && i.y == 0).length, 1);
    });

    ///
    /// (0,0)  (0,1)  (0,2)  (0,3)  (0,4)
    ///   -    -        t    --      t
    ///
    /// (1,0)  (1,1)  (1,2)  (1,3)  (1,4)
    ///  -       -      -    ---    ---
    ///
    /// (2,0)  (2,1)  (2,2)  (2,3)  (2,4)
    ///  xx      -      t    ---      4
    ///
    /// (3,0)  (3,1)  (3,2)  (3,3)  (3,4)
    ///   3    [t]    [t]    [t]     3
    ///
    /// (4,0)  (4,1)  (4,2)  (4,3)  (4,4)
    ///   2      1    start    1      2
    ///
    ///
    test('test  3 targets blocked path to next one ', () {
      astar.resetNodes();
      final targets = astar.findTargets(
          start: const Point(4, 2),
          targets: [
            // found
            Point(3, 1),
            Point(3, 2),
            Point(3, 3),
            // blocked
            Point(2, 2),
            // not found
            Point(0, 2),
            Point(0, 4),
          ],
          steps: 4);

      expect(targets.length, 3); // Check number of cols
    });
  });

// (0,0)  (1,0)  (2,0)  (3,0)  (4,0)
//   start  -      -      -      -

// (0,1)  (1,1)  (2,1)  (3,1)  (4,1)
//   -      -      -      -      -

// (0,2)  (1,2)  (2,2)  (3,2)  (4,2)
//   xx     t      -      -      -

// (0,3)  (1,3)  (2,3)  (3,3)  (4,3)
//   -      -      -      -      -

// (0,4)  (1,4)  (2,4)  (3,4)  (4,4)
//   -      -      -      -      t

  test('find targets around a barrier', () {
    astar.resetNodes();
    final targets = astar.findTargets(
        start: const Point(0, 0),
        targets: [const Point(1, 2), const Point(4, 4)],
        steps: 8);

    expect(targets.length, 2);
    expect(targets.firstWhere((p) => p.x == 1 && p.y == 2).distance, 3);
    expect(targets.firstWhere((p) => p.x == 4 && p.y == 4).distance, 8);
  });
}
