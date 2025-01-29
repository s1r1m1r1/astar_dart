import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:astar_dart/src/find_steps_ext.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final AStarManhattan astar;
  setUpAll(() {
    astar = AStarManhattan(
        rows: 7, columns: 7 );
    astar.setBarriers([
      const BarrierPoint(2, 0, barrier: Barrier.block),
      // const BarrierPoint(3, 2, barrier: Barrier.block),
    ]);
    astar.calculateGrid();
  });
  group('test 1', () {
    test('test 1', () async {
      final path = await astar.findSteps(start: const Point(0, 0), steps: 2);
      expect(path.length , 5); // Check number of cols
    });
    test('test 2', () async {
      final path = await astar.findSteps(start: const Point(6, 6), steps: 2);
      expect(path.length, 6); // Check number of cols
    });

    test('test 3', () async {
      final path = (await astar.findSteps(start: const Point(3, 3), steps: 2));
      expect(path.length == 13, true); // Check number of cols
    });
  });
}
