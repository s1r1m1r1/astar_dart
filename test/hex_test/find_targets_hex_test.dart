import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:astar_dart/src/find_steps_ext.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final AStarHex astar;
  setUpAll(() {
    astar = AStarHex.useList(
        rows: 7,
        columns: 7,
        barriers: [
          const Point(1, 0),
          const Point(1, 1),
        ].toListBarrier(Barrier.block));
    // astar.setBarriers(<Point<int>>[].toListBarrier(Barrier.block));

  });

  // top-left to bottom-right
  group('test AStarHex find targets', () {
    test(
      'test 1',
      () async {
        final path = await astar.findTargets(
          start: const Point(0, 0),
          targets: const [
            Point(6, 6),
            Point(5, 5),
            Point(2, 0),
          ],
        );
        expect(path[0].distance, 5.0); // Check number of cols
        expect(path[1].distance, 10.0); // Check number of cols
        expect(path[2].distance, 12.0); // Check number of cols
      },
    );
  });
}
