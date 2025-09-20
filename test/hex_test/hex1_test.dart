import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:test/test.dart';

void main() {
  // Removed the shared 'astar' instance declared here.
  // late final AStarHex astar;

  // No longer need setUpAll since a new instance is created for each test.
  // setUpAll(() {
  //   astar = AStarHex(
  //     rows: 7,
  //     columns: 7,
  //     gridBuilder: (x, y) {
  //       return ANode(x: x, y: y, neighbors: []);
  //     },
  //   );
  //   astar.addNeighbors();
  // });

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

    test('find path from (3, 2) to (4, 3) has length 2', () {
      final path =
          (astar.findPath(start: const Point(3, 2), end: const Point(4, 3)))
              .toPointList();
      expect(path.length, 3);
      expect(path.first, Point(4, 3));
      expect(path.last, Point(3, 2));
    });

    test('find path from (6, 6) to (0, 0) has length 12', () {
      final path =
          (astar.findPath(start: const Point(6, 6), end: const Point(0, 0)))
              .toPointList();
      expect(path.length, 13);
      expect(path.first, Point(0, 0));
      expect(path.last, Point(6, 6));
    });

    test('find path from (0, 6) to (6, 0) has length 6', () {
      final path =
          (astar.findPath(start: const Point(0, 6), end: const Point(6, 0)))
              .toPointList();
      expect(path.length, 7);
      expect(path.first, Point(6, 0));
      expect(path.last, Point(0, 6));
    });

    test('find path from (3, 3) to (0, 0) has length 6', () {
      final path =
          (astar.findPath(start: const Point(3, 3), end: const Point(0, 0)))
              .toPointList();
      expect(path.length, 7);
      expect(path.first, Point(0, 0));
      expect(path.last, Point(3, 3));
    });

    test('find path from (3, 3) to (0, 6) has length 3', () {
      final path =
          (astar.findPath(start: const Point(3, 3), end: const Point(0, 6)))
              .toPointList();
      expect(path.length, 4);
      expect(path.first, Point(0, 6));
      expect(path.last, Point(3, 3));
    });

    test('find path from (3, 3) to (6, 0) has length 3', () {
      final path =
          (astar.findPath(start: const Point(3, 3), end: const Point(6, 0)))
              .toPointList();
      expect(path.length, 4);
      expect(path.first, Point(6, 0));
      expect(path.last, Point(3, 3));
    });

    test('find path from (3, 3) to (6, 6) has length 6', () {
      final path =
          (astar.findPath(start: const Point(3, 3), end: const Point(6, 6)))
              .toPointList();
      expect(path.length, 7);
      expect(path.first, Point(6, 6));
      expect(path.last, Point(3, 3));
    });
  });
}
