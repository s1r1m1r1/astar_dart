import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final AStarManhattan astar;
  setUpAll(() {
    astar = AStarManhattan(
      rows: 4,
      columns: 4,
    );
    astar.calculateGrid();
  });
  group('test AStarSquareGrid manhattan', () {
    test('test AStarSquareGrid manhattan last point', () async {
      final path = (await astar.findPath(
              start: const Point(0, 0), end: const Point(3, 3)))
          .toPointList();
      expect(path.last, const Point(1, 0)); // Check number of cols
    });

    test('test AStarSquareGrid manhattan first point not start point',
        () async {
      final path = (await astar.findPath(
              start: const Point(0, 0), end: const Point(3, 3)))
          .toPointList();
      expect(path.first != const Point(0, 0), true); // Check number of cols
    });

    test(
        'test AStarSquareGrid manhattan neighbors DiagonalMovement.manhattan return List.empty()',
        () async {
      final path = (await astar.findPath(
              start: const Point(0, 0), end: const Point(0, 1)))
          .toPointList();
      expect(path.length, 0); // Check number of cols
    });

    test(
        'test AStarSquareGrid manhattan  neighbors DiagonalMovement.manhattan diagonal return path',
        () async {
      final path = (await astar.findPath(
              start: const Point(0, 0), end: const Point(1, 1)))
          .toPointList();
      expect(path.length, 2); // Check number of cols
    });
  });
}
