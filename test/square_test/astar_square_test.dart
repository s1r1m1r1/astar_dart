import 'package:astar_dart/astar_dart.dart';
import 'package:test/test.dart';

void main() {
  late AStarManhattan astar;

  setUpAll(() {
    astar = AStarManhattan(rows: 10, columns: 10);
    // astar.calculateGrid();
  });

  setUp(() {
    astar = AStarManhattan(rows: 10, columns: 10);
  });

  tearDownAll(() {
    astar.resetNodes(resetBarrier: true);
  });

  tearDown(() {
    astar.resetNodes(resetBarrier: true);
  });

  group('AStarSquare test 1', () {
    test('Finds path in simple grid', () {
      astar.addNeighbors();
      final path =
          astar.findPath(start: const (x: 0, y: 0), end: const (x: 9, y: 9));
      expect(path.isNotEmpty, true);
    });
    test('Finds path with obstacles', () {
      // astar.calculateGrid();
      astar.resetNodes();
      astar
        ..setBarrier(x: 4, y: 4, isBarrier: true)
        ..setBarrier(x: 4, y: 5, isBarrier: true)
        ..setBarrier(x: 5, y: 4, isBarrier: true)
        ..setBarrier(x: 5, y: 5, isBarrier: true);

      astar.addNeighbors();
      final path =
          astar.findPath(start: const (x: 0, y: 0), end: const (x: 9, y: 9));
      expect(path.isNotEmpty, true);
    });
  });
  group('AStarSquare test 2', () {
    test('No path if blocked', () {
      astar.resetNodes(resetBarrier: true);
      astar.setBarrier(x: 5, y: 5, isBarrier: true);

      astar.addNeighbors();
      final path =
          astar.findPath(start: const (x: 5, y: 4), end: const (x: 5, y: 6));
      expect(path.length, 5);
      expect(path.last.x, 5);
      expect(path.last.y, 4);
      expect(path.first.x, 5);
      expect(path.first.y, 6);
    });
  });

  group('AStarSquare test 3', () {
    test('Path contains correct nodes (deep equality)', () {
      astar.resetNodes(resetBarrier: true);

      astar.addNeighbors();
      final path =
          astar.findPath(start: const (x: 0, y: 0), end: const (x: 0, y: 3));
      expect(path.length, 4);
      expect(path.last.x, 0);
      expect(path.last.y, 0);
      expect(path.first.x, 0);
      expect(path.first.y, 3);
    });
  });
}
