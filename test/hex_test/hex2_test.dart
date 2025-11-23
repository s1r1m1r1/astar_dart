import 'package:astar_dart/astar_dart.dart';
import 'package:test/test.dart';

void main() {
  group('test AStarHex with barriers', () {
    // Declare a local astar instance for this group.
    late AStarHex astar;

    // Use setUp to create a new instance for each test.
    setUp(() {
      astar = AStarHex(
          rows: 7,
          columns: 7,
          gridBuilder: (int x, int y) {
            // Re-apply the barriers for each test.
            // if ((x == 3 && y == 2) ||
            //     (x == 3 && y == 3) ||
            //     (x == 3 && y == 4)) {
            //   return ANode(x: x, y: y, neighbors: [], isBarrier: true);
            // }
            return ANode(x: x, y: y, neighbors: []);
          });
      astar.addNeighbors();
    });

    tearDown(() {
      // Clean up after each test.
      astar.resetNodes();
    });

    test('find path from (0, 0) to (6, 6) with barriers has length 12', () {
      final path =
          (astar.findPath(start: const (x: 0, y: 0), end: const (x: 6, y: 6)));
      expect(path.length, 13);
    });

    test('find path from (6, 6) to (0, 0) with barriers has length 12', () {
      final path =
          (astar.findPath(start: const (x: 6, y: 6), end: const (x: 0, y: 0)))
              .toPointList();
      expect(path.length, 13);
    });

    test('find path from (0, 6) to (6, 6) has a length of 7', () {
      // The path should go around the barriers, which affects the length.
      final path =
          (astar.findPath(start: const (x: 0, y: 6), end: const (x: 6, y: 6)))
              .toPointList();
      expect(path.length, 7);
      expect(path.first.x, 6);
      expect(path.first.y, 6);

      expect(path.last.x, 0);
      expect(path.last.y, 6);
    });

    test('find path from (0, 6) to (6, 0) has a length of 9', () {
      final path =
          (astar.findPath(start: const (x: 0, y: 6), end: const (x: 6, y: 0)))
              .toPointList();
      expect(path.length, 7);
      expect(path.first.x, 6);
      expect(path.first.y, 0);

      expect(path.last.x, 0);
      expect(path.last.y, 6);
    });
  });
}
