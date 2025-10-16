import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:test/test.dart';

void main() {
  late final AStarManhattan astar;
  setUpAll(() {
    astar = AStarManhattan(
      rows: 5,
      columns: 5,
      gridBuilder: (x, y) {
        if (x == 1 && y >= 0 && y < 2) {
          return ANode(x: x, y: y, neighbors: [], weight: 2);
        }
        if (x == 2 && y >= 0 && y < 3) {
          return ANode(x: x, y: y, neighbors: [], weight: 3);
        }
        if (x == 2 && y == 3) {
          return ANode(x: x, y: y, neighbors: [], weight: 5);
        }
        return ANode(x: x, y: y, neighbors: [], weight: 1);
      },
    );
    astar.setBarrier(
      x: 0,
      y: 2,
      isBarrier: true,
    );
    astar.addNeighbors();
    final result = astar.findStepsTargets(
      start: const Point(2, 2),
      obstacles: [
        Point(3, 3),
        Point(4, 4),
        Point(3, 1),
        Point(4, 1),
      ],
      targets: const [
        Point(1, 4),
        Point(3, 4),
        Point(0, 3),
        Point(3, 0),
      ],
      steps: 6,
    );

    final steps = result.steps;
    final targets = result.targets;
  });

// (0,0) (1,0) (2,0) (3,0) (4,0)
//   1     2     3     1     1
//  4{5}  3{5}         t
//
// (0,1) (1,1) (2,1) (3,1) (4,1)
//   1     2     3     1     1
//  3{4}  2{3}  1{3}   o     o
//
// (0,2) (1,2) (2,2) (3,2) (4,2)
//   xx    1     3     1     1
//        1{1}  start 1{1}  2{2}
//
//
// (0,3) (1,3) (2,3) (3,3) (4,3)
//   1     1     5     1     1
//  [t]   2{2}  1{5}   o   3{3}
//
// (0,4) (1,4) (2,4) (3,4) (4,4)
//   1     1     1     1     1
//        [T]          t     o
//
  group('test reconstruct', () {
    test('finds targets and steps within the limit', () {
      final result = astar.reconstruct(Point(1, 3));
      expect(result.length, 3);
    });
    test('finds targets and steps within the limit', () {
      final result = astar.reconstruct(Point(0, 0));
      expect(result.length, 5);
    });
    test('finds targets and steps within the limit', () {
      final result = astar.reconstruct(Point(1, 3));
      expect(result.length, 3);
    });
    test('finds targets and steps within the limit', () {
      final result = astar.reconstruct(Point(0, 3));
      expect(result.length, 4);
    });
    test('finds targets and steps within the limit', () {
      final result = astar.reconstruct(Point(4, 3));
      expect(result.length, 4);
    });
    test('obstacle have one item itself', () {
      final result = astar.reconstruct(Point(3, 1));
      expect(result.length, 1);
    });
    test('obstacle have one item itself', () {
      final result = astar.reconstruct(Point(0, 2));
      expect(result.length, 1);
    });
  });
}
