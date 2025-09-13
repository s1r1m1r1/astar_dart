import 'package:astar_dart/astar_dart.dart';
import 'package:test/test.dart';

void main() {
  late final AStarHex astar;
  setUpAll(() {
    astar = AStarHex(
      rows: 7,
      columns: 7,
      gridBuilder: (x, y) {
        return ANode(x: x, y: y, neighbors: []);
      },
    );
    astar.addNeighbors();
  });

  // top-left to bottom-right
  group('test AStarHex simple', () {
    test('test 1', () {
      astar.addNeighbors();
      final path = (astar.findPath(start: (x: 3, y: 2), end: (x: 4, y: 3)))
          .toPointList();
      expect(path.length, 2); // Check number of cols
    });

    test('test 2', () {
      astar.addNeighbors();
      final path = (astar.findPath(start: (x: 6, y: 6), end: (x: 0, y: 0)))
          .toPointList();
      expect(path.length, 12); // Check number of cols
    });

    test('test 3', () {
      astar.resetNodes();
      final path = (astar.findPath(start: (x: 0, y: 6), end: (x: 6, y: 0)))
          .toPointList();
      expect(path.length, 6); // Check number of cols
    });
    test('test 4', () {
      astar.resetNodes();
      final path = (astar.findPath(start: (x: 0, y: 6), end: (x: 6, y: 0)))
          .toPointList();
      expect(path.length, 6); // Check number of cols
    });
    test('test 5', () {
      astar.resetNodes();
      final path = (astar.findPath(start: (x: 3, y: 3), end: (x: 0, y: 0)))
          .toPointList();
      expect(path.length, 6); // Check number of cols
    });
    test('test 6', () {
      astar.resetNodes();
      final path = (astar.findPath(start: (x: 3, y: 3), end: (x: 0, y: 6)))
          .toPointList();
      expect(path.length, 3); // Check number of cols
    });
    test('test 7', () {
      astar.resetNodes();
      final path = (astar.findPath(start: (x: 3, y: 3), end: (x: 6, y: 0)))
          .toPointList();
      expect(path.length, 3); // Check number of cols
    });
    test('test 8', () {
      astar.resetNodes();
      final path = (astar.findPath(start: (x: 3, y: 3), end: (x: 6, y: 6)))
          .toPointList();
      expect(path.length, 6); // Check number of cols
    });
  });
}
