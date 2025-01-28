import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final AStarHex astar;
  setUpAll(() {
    astar = AStarHex.useList(rows: 7, columns: 7, barriers: [
      const BarrierPoint(3, 2, barrier: Barrier.block),
      const BarrierPoint(3, 3, barrier: Barrier.block),
      const BarrierPoint(3, 4, barrier: Barrier.block),
    ]);
    // astar.setBarriers(<Point<int>>[].toListBarrier(Barrier.block));

  });

  // top-left to bottom-right
  group('test AStarHex with barriers', () {
    test('test 1', () async {
      final path = (await astar.findPath(
              start: const Point(0, 0), end: const Point(6, 6)))
          .toPointList();
      expect(path.length, 12); // Check number of cols
    });

    test('test 2', () async {
      final path = (await astar.findPath(
              start: const Point(6, 6), end: const Point(0, 0)))
          .toPointList();
      expect(path.length, 12); // Check number of cols
    });

    test('test 3', () async {
      final path = (await astar.findPath(
              start: const Point(0, 6), end: const Point(6, 0)))
          .toPointList();
      expect(
          path.length >= 7 && path.length <= 8, true); // Check number of cols
    });
    test('test 4', () async {
      final path = (await astar.findPath(
              start: const Point(0, 6), end: const Point(6, 0)))
          .toPointList();
      expect(
          path.length >= 7 && path.length <= 8, true); // Check number of cols
    });
  });
}
