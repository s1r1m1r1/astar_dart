import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:astar_dart/src/find_steps_ext.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final AStarManhattan astar;
  setUpAll(() {
    astar = AStarManhattan(rows: 7, columns: 7);
    astar.setBarrier(
      x: 2,
      y: 0,
      barrier: Barrier.block,
    );
    astar.addNeighbors();
  });
  group('test steps', () {
    test('test top-left 2 steps with one barrier', () {
      astar.resetNodes();
      final path = astar.findSteps(start: const Point(0, 0), steps: 2);
      expect(path.length, 5); // Check number of cols
    });
    test('test top-left 3 steps with one barrier', () {
      astar.resetNodes();
      final path = astar.findSteps(start: const Point(0, 0), steps: 3);
      expect(path.length, 8); // Check number of cols
    });
    test('test bottom-right 2 steps', () {
      astar.resetNodes();
      final path = astar.findSteps(start: const Point(6, 6), steps: 2);
      expect(path.length, 6); // Check number of cols
    });
    test('test bottom-right 3 steps', () {
      astar.resetNodes();
      final path = astar.findSteps(start: const Point(6, 6), steps: 3);
      expect(path.length, 10); // Check number of cols
    });

    test('test center 2 steps', () {
      astar.resetNodes();
      final path = (astar.findSteps(start: const Point(3, 3), steps: 2));
      expect(path.length, 13); // Check number of cols
    });
    test('test center 3 steps', () {
      astar.resetNodes();
      final path = (astar.findSteps(start: const Point(3, 3), steps: 3));
      expect(path.length, 25); // Check number of cols
    });
  });
}
