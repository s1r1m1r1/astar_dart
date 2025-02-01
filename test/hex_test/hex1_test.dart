import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:astar_dart/src/astar_hex.dart';
import 'package:flutter_test/flutter_test.dart';

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
    test('test 1', () async {
      final path = (await astar.findPath(
              start: const Point(0, 0), end: const Point(6, 6)))
          .toPointList();
      expect(path.length, 12); // Check number of cols
    });

    test('test 2', () async {
      final path = (await astar.findPath(
              start: const Point(6, 6), end: const Point(0, 0)))
          .toPointList();
      expect(path.length, 12); // Check number of cols
    });

    test('test 3', () async {
      final path = (await astar.findPath(
              start: const Point(0, 6), end: const Point(6, 0)))
          .toPointList();
      expect(path.length, 6); // Check number of cols
    });
    test('test 4', () async {
      final path = (await astar.findPath(
              start: const Point(0, 6), end: const Point(6, 0)))
          .toPointList();
      expect(path.length, 6); // Check number of cols
    });
    test('test 5', () async {
      final path = (await astar.findPath(
              start: const Point(3, 3), end: const Point(0, 0)))
          .toPointList();
      expect(path.length, 6); // Check number of cols
    });
    test('test 6', () async {
      final path = (await astar.findPath(
              start: const Point(3, 3), end: const Point(0, 6)))
          .toPointList();
      expect(path.length, 3); // Check number of cols
    });
    test('test 7', () async {
      final path = (await astar.findPath(
              start: const Point(3, 3), end: const Point(6, 0)))
          .toPointList();
      expect(path.length, 3); // Check number of cols
    });
    test('test 8', () async {
      final path = (await astar.findPath(
              start: const Point(3, 3), end: const Point(6, 6)))
          .toPointList();
      expect(path.length, 6); // Check number of cols
    });
  });
}
