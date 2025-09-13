import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:test/test.dart';

void main() {
  late final AStarManhattan astar;
  setUpAll(() {
    astar = AStarManhattan(rows: 5, columns: 5);
    astar.setBarrier(
      x: 2,
      y: 0,
      isBarrier: true,
    );
    astar.addNeighbors();
  });
  group('find targets', () {
    test('test not targets , no path', () {
      astar.resetNodes();
      final targets = astar.findTargets(
          start: const Point(0, 0),
          targets: [Point(3, 0), Point(4, 4), Point(3, 3), Point(1, 4)],
          maxSteps: 3);

      expect(targets.length, 0); // Check number of cols
    });
    test('test 2  ', () {
      astar.resetNodes();
      final targets = astar.findTargets(
          start: const Point(0, 0),
          targets: [
            // found
            Point(3, 1),
            Point(2, 2),
            Point(0, 4),
            // not found
            Point(3, 2),
            Point(3, 3),
          ],
          maxSteps: 3);

      expect(targets.length, 3); // Check number of cols
    });
    test('test  3 targets blocked path to next one ', () {
      astar.resetNodes();
      final targets = astar.findTargets(
          start: const Point(0, 0),
          targets: [
            // found
            Point(0, 2),
            Point(1, 2),
            Point(2, 2),
            // blocked
            Point(0, 4),
            // not found
            Point(3, 2),
            Point(3, 3),
          ],
          maxSteps: 3);

      expect(targets.length, 3); // Check number of cols
    });

    test('test ally blocked path to target', () {
      astar.resetNodes();
      final targets = astar.findTargets(
          start: const Point(0, 0),
          targets: [
            // founded
            Point(2, 2),
            // blocked
            Point(0, 4),
            // not found
            Point(3, 2),
            Point(3, 3),
          ],
          maxSteps: 3);

      expect(targets.length, 2); // Check number of cols
    });
  });
}
