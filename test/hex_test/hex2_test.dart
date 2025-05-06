import 'package:astar_dart/astar_dart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final AStarHex astar;
  setUpAll(() {
    astar = AStarHex(
        rows: 7,
        columns: 7,
        gridBuilder: (int x, int y) {
          if ((x == 3 && y == 2) || (x == 3 && y == 3) || (x == 3 && y == 4)) {
            return ANode(x: x, y: y, neighbors: [], barrier: Barrier.block);
          }
          return ANode(x: x, y: y, neighbors: []);
        });
    astar.addNeighbors();
    // astar.setBarriers(<Point<int>>[].toListBarrier(Barrier.block));
  });

  // top-left to bottom-right
  group('test AStarHex with barriers', () {
    test('test 1', () {
      astar.resetNodes();
      final path = (astar.findPath(start: (x: 0, y: 0), end: (x: 6, y: 6)))
          .toPointList();
      expect(path.length, 12); // Check number of cols
    });

    test('test 2', () {
      astar.resetNodes();
      final path = (astar.findPath(start: (x: 6, y: 6), end: (x: 0, y: 0)))
          .toPointList();
      expect(path.length, 12); // Check number of cols
    });

    test('test 3', () {
      astar.resetNodes();
      final path = (astar.findPath(start: (x: 0, y: 6), end: (x: 6, y: 0)))
          .toPointList();
      expect(
          path.length >= 7 && path.length <= 8, true); // Check number of cols
    });
    test('test 4', () {
      astar.resetNodes();
      final path = (astar.findPath(start: (x: 0, y: 6), end: (x: 6, y: 0)))
          .toPointList();
      expect(
          path.length >= 7 && path.length <= 8, true); // Check number of cols
    });
  });
}
