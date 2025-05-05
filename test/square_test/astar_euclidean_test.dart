import 'package:astar_dart/astar_dart.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AStarEuclidean astar;

  setUpAll(() {
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
    // astar.calculateGrid();
  });

  group('AStarSquare (Euclidean)', () {
    test('Finds path in simple grid (Euclidean)', () {
      final path = astar.findPath(start: (x: 0, y: 0), end: (x: 9, y: 9));
      final points = path.toPointList();
      expect(points.length, 9);
    });
  });
}
