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

  group('test steps', () {
// (0,0) (1,0) (2,0) (3,0) (4,0)
// Start   1     2     3     4
// (0,1) (1,1) (2,1) (3,1) (4,1)
//   1     2     3     4     5
// (0,2) (1,2) (2,2) (3,2) (4,2)
//   xx    T     4     5     -
// (0,3) (1,3) (2,3) (3,3) (4,3)
//   -     -     5     -     -
// (0,4) (1,4) (2,4) (3,4) (4,4)
//   -     -     -     -     T

    test('finds targets and steps within the limit', () {
      astar.resetNodes();
      final result = astar.findStepsTargets(
        start: const Point(0, 0),
        targets: [const Point(1, 2), const Point(4, 4)],
        steps: 5,
      );

      final steps = result.steps;
      final targets = result.targets;

      expect(steps.length, 13); // Total reachable nodes in 5 steps
      expect(targets.length, 1);
      expect(targets.first, Point(1, 2));
      expect(targets.first.distance, 3);
    });

// (0,0) (1,0) (2,0) (3,0) (4,0)
//   S     T1    -     -     -
// (0,1) (1,1) (2,1) (3,1) (4,1)
//   -     -     -     T2    -
// (0,2) (1,2) (2,2) (3,2) (4,2)
//   xx    -     -     -     -
// (0,3) (1,3) (2,3) (3,3) (4,3)
//   -     -     -     -     T3
// (0,4) (1,4) (2,4) (3,4) (4,4)
//   -     -     -     -     -

    test('finds multiple targets with different distances', () {
      astar.resetNodes();
      final result = astar.findStepsTargets(
        start: const Point(0, 0),
        targets: [const Point(1, 0), const Point(3, 1), const Point(4, 3)],
        steps: 8,
      );

      final targets = result.targets;

      expect(targets.length, 3);
      expect(targets.where((p) => p.x == 1 && p.y == 0).first.distance, 1);
      expect(targets.where((p) => p.x == 3 && p.y == 1).first.distance, 4);
      expect(targets.where((p) => p.x == 4 && p.y == 3).first.distance, 7);
    });

    test('no steps found when steps limit is zero', () {
      astar.resetNodes();
      final result = astar.findStepsTargets(
        start: const Point(0, 0),
        targets: [const Point(1, 0)],
        steps: 0,
      );

      final steps = result.steps;
      final targets = result.targets;

      // The start point itself is a "step" at distance 0
      expect(steps.length, 1);
      expect(targets, isEmpty);
    });

    ///
    /// (0,0) (1,0) (2,0) (3,0) (4,0)
    /// Start   1     2     3     4
    /// (0,1) (1,1) (2,1) (3,1) (4,1)
    ///  1      2     3     4     5
    /// (0,2) (1,2) (2,2) (3,2) (4,2)
    ///  xx     T     O     5     -
    /// (0,3) (1,3) (2,3) (3,3) (4,3)
    ///  -     -     -     -     -
    /// (0,4) (1,4) (2,4) (3,4) (4,4)
    ///  -     -     -     -     T
    ///
    ///
    /// The global barrier is at (0,2) (marked with 'xx').
    /// The temporary obstacle is at (2,2) (also marked with 'xx').
    /// The steps limit is 5.
    ///
    test('finds targets and steps with temporary obstacles', () {
      astar.resetNodes();
      final result = astar.findStepsTargets(
        start: const Point(0, 0),
        targets: [const Point(1, 2), const Point(4, 4)],
        obstacles: [const Point(2, 2)],
        steps: 5,
      );

      final steps = result.steps;
      final targets = result.targets;

      expect(steps.length, 11);
      expect(targets.length, 1);
      expect(targets.first, const Point(1, 2));
      expect(targets.first.distance, 3);
    });
  });
}
