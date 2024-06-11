import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final AStarSquareGrid astar;
  setUpAll(() {
    astar = AStarSquareGrid(
        rows: 4, columns: 4, diagonalMovement: DiagonalMovement.euclidean);
    astar.calculateGrid();
  });
  group('test AStarSquareGrid euclidean', () {
    test('test last point', () {
      final path = astar
          .findPath(start: const Point(0, 0), end: const Point(3, 3))
          .toPointList();
      expect(path.last, const Point(3, 3)); // Check number of cols
    });

    test('test first point not start point', () {
      final path = astar
          .findPath(start: const Point(0, 0), end: const Point(3, 3))
          .toPointList();
      expect(path.first != const Point(0, 0), true); // Check number of cols
    });

    test('test neighbors DiagonalMovement.manhattan return List.empty()', () {
      final path = astar
          .findPath(start: const Point(0, 0), end: const Point(0, 1))
          .toPointList();
      expect(path.isEmpty, true); // Check number of cols
    });

    test('test neighbors DiagonalMovement.manhattan diagonal return List.empty()', () {
      final path = astar
          .findPath(start: const Point(0, 0), end: const Point(1, 1))
          .toPointList();
      expect(path.isEmpty, true); // Check number of cols
    });
  });
}
