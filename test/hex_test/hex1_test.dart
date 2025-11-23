import 'package:astar_dart/astar_dart.dart';
import 'package:test/test.dart';

void main() {
  group('test AStarHex simple', () {
    // Declare the astar variable here so it is local to this group.
    late AStarHex astar;

    // The setUp function now creates a new instance for each test.
    setUp(() {
      astar = AStarHex(
        rows: 7,
        columns: 7,
        gridBuilder: (x, y) {
          return ANode(x: x, y: y, neighbors: []);
        },
      );
      astar.addNeighbors();
    });

    tearDown(() {
      astar.resetNodes();
    });

    /// (x0,y0)  (x1,y0) (x2,y0) (x3,y0) (x4,y0) (x5,y0) (x6,y0)
    ///
    ///    (x0,y1)  (x1,y1) (x2,y1) (x3,y1) (x4,y1) (x5,y1) (x6,y1)
    ///
    ///       (x0,y2)  (x1,y2) (x2,y2) (x3,y2) (x4,y2) (x5,y2) (x6,y2)
    ///
    ///           (x0,y3)  (x1,y3) (x2,y3) (x3,y3) (x4,y3) (x5,y3) (x6,y3)
    ///
    ///               (x0,y4)  (x1,y4) (x2,y4) (x3,y4) (x4,y4) (x5,y4) (x6,y4)
    ///
    ///                    (x0,y5)  (x1,y5) (x2,y5) (x3,y5) (x4,y5) (x5,y5) (x6,y5)
    ///
    ///                         (x0,y6)  (x1,y6) (x2,y6) (x3,y6) (x4,y6) (x5,y6) (x6,y6)
    ///

    test('find path from (3, 2) to (4, 3) has length 2', () {
      final path =
          (astar.findPath(start: const (x: 3, y: 2), end: const (x: 4, y: 3)));
      expect(path.length, 3);
      // expect(path.first, Point(4, 3));
      // expect(path.last, Point(3, 2));
    });

    test('find path from (6, 6) to (0, 0) has length 12', () {
      final path =
          (astar.findPath(start: const (x: 6, y: 6), end: const (x: 0, y: 0)))
              .toPointList();
      expect(path.length, 13);
      expect(path.first, (x: 0, y: 0));
      expect(path.last, (x: 6, y: 6));
    });

    test('find path from (0, 6) to (6, 0) has length 6', () {
      final path =
          (astar.findPath(start: const (x: 0, y: 6), end: const (x: 6, y: 0)))
              .toPointList();
      expect(path.length, 7);
      expect(path.first, (x: 6, y: 0));
      expect(path.last, (x: 0, y: 6));
    });

    test('find path from (3, 3) to (0, 0) has length 6', () {
      final path =
          (astar.findPath(start: const (x: 3, y: 3), end: const (x: 0, y: 0)))
              .toPointList();
      expect(path.length, 7);
      expect(path.first.x, 0);
      expect(path.first.y, 0);
      expect(path.last.x, 3);
      expect(path.last.y, 3);
    });

    test('find path from (3, 3) to (0, 6) has length 3', () {
      final path =
          (astar.findPath(start: const (x: 3, y: 3), end: const (x: 0, y: 6)))
              .toPointList();
      expect(path.length, 4);
      expect(path.first, (x: 0, y: 6));
      expect(path.last, (x: 3, y: 3));
    });

    test('find path from (3, 3) to (6, 0) has length 3', () {
      final path =
          (astar.findPath(start: const (x: 3, y: 3), end: const (x: 6, y: 0)))
              .toPointList();
      expect(path.length, 4);
      expect(path.first, (x: 6, y: 0));
      expect(path.last, (x: 3, y: 3));
    });

    test('find path from (3, 3) to (6, 6) has length 6', () {
      final path =
          (astar.findPath(start: const (x: 3, y: 3), end: const (x: 6, y: 6)))
              .toPointList();
      expect(path.length, 7);
      expect(path.first, (x: 6, y: 6));
      expect(path.last, (x: 3, y: 3));
    });
  });
}
