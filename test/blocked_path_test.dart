import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final AStarSquareGrid astar;
  setUpAll(() {
    astar = AStarSquareGrid(
        rows: 6, columns: 6, diagonalMovement: DiagonalMovement.euclidean);
    astar.setBarriers(<Point<int>>[
      const Point(0, 3),
      const Point(1, 3),
      const Point(2, 3),
      const Point(3, 3),
      const Point(4, 3),
      const Point(5, 3),
    ].toListBarrier(Barrier.block));
    astar.calculateGrid();
  });
  group('test blocked path', () {
    test('test if blocked ', () async {
      final path = await astar.findPath(
          start: const Point(0, 0), end: const Point(5, 5));
      expect(path.isEmpty, true); // Check number of cols
    });

    test('test if not blocked ', () async {
      final path = await astar.findPath(
          start: const Point(0, 0), end: const Point(5, 2));
      expect(path.isNotEmpty, true); // Check number of cols
    });
  });
}
