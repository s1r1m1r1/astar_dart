
import 'package:astar_dart/astar_dart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late final AStarEuclidean astar;
  setUpAll(() {
    astar = AStarEuclidean(
        rows: 6,
        columns: 6,
        gridBuilder: (int x, int y) {
          if ((x == 0 && y == 3) ||
              (x == 1 && y == 3) ||
              (x == 2 && y == 3) ||
              (x == 3 && y == 3) ||
              (x == 4 && y == 3) ||
              (x == 5 && y == 3)) {
            return ANode(x: x, y: y, neighbors: [], barrier: Barrier.block);
          }
          return ANode(x: x, y: y, neighbors: [], barrier: Barrier.pass);
        });
    astar.addNeighbors();
    // 0,0   1,0   2,0   3,0   4,0   5,0
    //  1  *  1  *  1  *  1  *  1  *  1
    //  *     *     *     *     *     *
    // 0,1 - 1,1 - 2,1 - 3,1 - 4,1 - 5,1
    //  1  *  1  *  1  *  1  *  1  *  1
    //  *     *     *     *     *     *
    // 0,2 - 1,2 - 2,2 - 3,2 - 4,2 - 5,2
    //  1  *  1  *  1  *  1  *  1  *  1
    //
    // 0,3   1,3   2,3   3,3   4,3   5,3
    //  x     x     x     x     x    x
    //
    // 0,4 - 1,4 - 2,4 - 3,4 - 4,4 - 5,4
    //  1  *  1  *  1  *  1  *  1  *  1
    //  *     *     *     *     *     *
    // 0,5 - 1,5 - 2,5 - 3,5 - 4,5 - 5,5
    //  1  *  1  *  1  *  1  *  1  *  1
    // astar.setBarriers(<Point<int>>[
    //   const Point(0, 3),
    //   const Point(1, 3),
    //   const Point(2, 3),
    //   const Point(3, 3),
    //   const Point(4, 3),
    //   const Point(5, 3),
    // ].toListBarrier(Barrier.block));
    // astar.calculateGrid();
  });
  group('test blocked path', () {
    test('test if blocked ', () async {
      final path = await astar.findPath(start: (x: 0, y: 0), end: (x: 5, y: 5));
      expect(path.isEmpty, true); // Check number of cols
    });

    test('test if not blocked ', () async {
      final path = await astar.findPath(start: (x: 0, y: 0), end: (x: 5, y: 2));
      expect(path.isNotEmpty, true); // Check number of cols
    });
  });
}
