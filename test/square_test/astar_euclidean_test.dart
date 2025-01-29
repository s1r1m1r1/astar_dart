import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AStarSquare astar;

  setUpAll(() {
    astar = AStarSquare(rows: 10, columns: 10,diagonalMovement: DiagonalMovement.manhattan); // Default is Euclidean
    astar.calculateGrid();
  });

  group('AStarSquare (Euclidean)', () {
    test('Finds path in simple grid (Euclidean)', () async {
      print('START');
      final path = await astar.findPath(
          start: const Point(0, 0), end: const Point(9, 9));
      expect(path.length, 10);
    });

//     test('Finds path with obstacles (Euclidean)', () async {
//       astar.setBarriers([
//         const BarrierPoint(4, 4, barrier: Barrier.block),
//         const BarrierPoint(4, 5, barrier: Barrier.block),
//         const BarrierPoint(5, 4, barrier: Barrier.block),
//         const BarrierPoint(5, 5, barrier: Barrier.block),
//       ]);
//       final path = await astar.findPath(
//           start: const Point(0, 0), end: const Point(9, 9));
//       expect(path.isNotEmpty, true);
//     });

//     test('No path if blocked (Euclidean)', () async {
//       astar.setBarrier(const BarrierPoint(5, 5, barrier: Barrier.block));
//       final path = await astar.findPath(
//           start: const Point(5, 4), end: const Point(5, 6));
//       expect(path.isEmpty, true);
//     });

//     test('Finds path with weighted points (Euclidean)', () async {
//       astar.setPoint(const WeightedPoint(5, 5, weight: 5));
//       final path = await astar.findPath(
//           start: const Point(0, 0), end: const Point(9, 9));
//       expect(path.isNotEmpty, true);
//     });

//     test('Finds steps within range (Euclidean)', () async {
//       final steps = await astar.findSteps(steps: 3, start: const Point(5, 5));
//       expect(steps.isNotEmpty, true);
//     });

//     test('Handles start and end being neighbors (Euclidean)', () async {
//       final path = await astar.findPath(
//           start: const Point(0, 0), end: const Point(0, 1));
//       expect(path.isEmpty, true);
//     });

//     test('Path contains correct nodes (deep equality, Euclidean)', () async {
//       final expectedPath = [
//         ANode(x: 0, y: 1, neighbors: [], weight: 1.0),
//         ANode(x: 0, y: 2, neighbors: [], weight: 1.0),
//         ANode(x: 0, y: 3, neighbors: [], weight: 1.0),
//       ];

//       final path = await astar.findPath(
//           start: const Point(0, 0), end: const Point(0, 3));

//       expect(
//         const ListEquality().equals(path, expectedPath.reversed.toList()),
//         true,
//       );
//     });
//   });

//   group('AStarSquare (Manhattan)', () {
//     // Added group for Manhattan tests
//     setUp(() {
//       astar.calculateGrid();
//       astar.setDiagonalMovement(DiagonalMovement.manhattan);
//     });

//     // ... (All the Manhattan tests from the previous example go here) ...
//     test('Finds path in simple grid (Manhattan)', () async {
//       final path = await astar.findPath(
//           start: const Point(0, 0), end: const Point(9, 9));
//       expect(path.isNotEmpty, true);
//       expect(path.length, 18); //Expected Manhattan path length
//     });

// // ... (rest of Manhattan tests)
  });
}
