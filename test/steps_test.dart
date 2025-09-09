import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:flutter_test/flutter_test.dart';

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
    test('test top-left 3 steps with one barrier', () {
      astar.resetNodes();
      final path = astar.findSteps(start: const Point(0, 0), steps: 3);
      // with barrier 2,0
      expect(path.length, 7); // Check number of cols
    });
    test('test bottom-right 2 steps', () {
      astar.resetNodes();
      final path = astar.findSteps(start: const Point(6, 6), steps: 2);
      expect(path.length, 5); // Check number of cols
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
  });
}
