import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final AStarEuclidean astar;
  setUpAll(() {
    astar = AStarEuclidean(
        rows: 4,
        columns: 4,
        gridBuilder: (int x, int y) {
          return ANode(
            x: x,
            y: y,
            neighbors: [],
          );
        });
    // astar.calculateGrid();
    astar.addNeighbors();
  });

  group('test AStarSquareGrid euclidean', () {
    test('test firs point is end point', () async {
      final path =
          (await astar.findPath(start: (x: 0, y: 0), end: (x: 3, y: 3)))
              .toPointList();
      expect(path.first, const Point(3, 3));
    });

    test('test last point is start ', () async {
      final path =
          (await astar.findPath(start: (x: 0, y: 0), end: (x: 3, y: 3)))
              .toPointList();
      expect(const [Point(0, 1), Point(1, 0), Point(1, 1)].contains(path.last),
          true);
    });

    test('test neighbors DiagonalMovement.manhattan return one item', () async {
      final path =
          (await astar.findPath(start: (x: 0, y: 0), end: (x: 0, y: 2)))
              .toPointList();
      expect(path.length, 2);
    });

    test('test neighbors DiagonalMovement.manhattan diagonal return one item',
        () async {
      final path =
          (await astar.findPath(start: (x: 0, y: 0), end: (x: 1, y: 1)))
              .toPointList();
      expect(path.length, 0);
    });
  });
}
