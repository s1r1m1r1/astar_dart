import 'package:astar_dart/astar_dart.dart';
import 'package:test/test.dart';

void main() {
  group('AStarSquare (Euclidean)', () {
    late AStarEuclidean astar;
    setUp(() {
      astar = AStarEuclidean(
          rows: 10,
          columns: 10,
          gridBuilder: (int x, int y) {
            return ANode(
              x: x,
              y: y,
              neighbors: [],
            );
          }); // Default is Euclidean
      astar.addNeighbors();
    });

    tearDown(() {
      astar.resetNodes(resetBarrier: true);
    });

    test('Finds path in simple grid (Euclidean)', () {
      final path =
          astar.findPath(start: const (x: 0, y: 0), end: const (x: 9, y: 9));
      expect(path.length, 10);
    });
  });
}
