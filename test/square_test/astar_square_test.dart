import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:test/test.dart';

void main() {
  late AStarManhattan astar;

  setUpAll(() {
    astar = AStarManhattan(rows: 10, columns: 10);
    // astar.calculateGrid();
  });

  setUp(() {
    astar = AStarManhattan(rows: 10, columns: 10);
  });

  tearDownAll(() {
    astar.resetNodes(resetBarrier: true);
  });

  tearDown(() {
    astar.resetNodes(resetBarrier: true);
  });

  group('AStarSquare test 1', () {
    test('Finds path in simple grid', () {
      astar.addNeighbors();
      final path = astar.findPath(start: Point(0, 0), end: Point(9, 9));
      expect(path.isNotEmpty, true);
    });
    test('Finds path with obstacles', () {
      // astar.calculateGrid();
      astar.resetNodes();
      astar
        ..setBarrier(x: 4, y: 4, isBarrier: true)
        ..setBarrier(x: 4, y: 5, isBarrier: true)
        ..setBarrier(x: 5, y: 4, isBarrier: true)
        ..setBarrier(x: 5, y: 5, isBarrier: true);

      astar.addNeighbors();
      final path = astar.findPath(start: Point(0, 0), end: Point(9, 9));
      expect(path.isNotEmpty, true);
    });
  });
  group('AStarSquare test 2', () {
    test('No path if blocked', () {
      astar.resetNodes(resetBarrier: true);
      astar.setBarrier(x: 5, y: 5, isBarrier: true);

      astar.addNeighbors();
      final path = astar.findPath(start: Point(5, 4), end: Point(5, 6));
      expect(path.length, 5);
      expect(path.last, Point(5, 4));
      expect(path.first, Point(5, 6));
    });
  });

  group('AStarSquare test 3', () {
    test('Path contains correct nodes (deep equality)', () {
      astar.resetNodes(resetBarrier: true);

      astar.addNeighbors();
      final path = astar.findPath(start: Point(0, 0), end: Point(0, 3));
      expect(path.length, 4);
      expect(path.last, Point(0, 0));
      expect(path.first, Point(0, 3));
    });
  });
}
