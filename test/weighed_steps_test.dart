// ignore_for_file: avoid_print

import 'package:astar_dart/astar_dart.dart';
import 'package:test/test.dart';

void main() {
  late final AStarManhattan astar;
  setUpAll(() {
    astar = AStarManhattan(
        rows: 7,
        columns: 7,
        gridBuilder: (x, y) {
          if (y == 0 && x > 0 && x < 4) {
            return ANode(x: x, y: y, neighbors: [], weight: 2);
          }
          if (y == 1 && x > 0 && x < 3) {
            return ANode(x: x, y: y, neighbors: [], weight: 3);
          }
          if (y == 2 && x > 0 && x < 3) {
            return ANode(x: x, y: y, neighbors: [], weight: 2);
          }
          if (y == 3 && x > 0 && x < 3) {
            return ANode(x: x, y: y, neighbors: [], weight: 2);
          }
          if (x == 3 && y == 2) {
            return ANode(x: x, y: y, neighbors: [], weight: 5);
          }
          return ANode(x: x, y: y, neighbors: [], weight: 1);
        });

    astar.addNeighbors();
  });

  group('test steps', () {
    /// (x,y)
    /// (0,0)  (1,0)  (2,0)  (3,0)  (4,0)  (5,0)  (6,0)
    ///         [2]    [2]    [2]
    /// start   1{2}   2{4}   3{6}      -      -      -
    ///
    /// (0,1)  (1,1)  (2,1)  (3,1)  (4,1)  (5,1)  (6,1)
    ///         [3]    [3]
    ///  1{1}   2{4}      -      -      -      -      -
    ///
    /// (0,2)  (1,2)  (2,2)  (3,2)  (4,2)  (5,2)  (6,2)
    ///         [2]    [2]    [5]
    /// 2{2}    3{4}   4{6}      -      -      -     -
    ///
    /// (0,3)  (1,3)  (2,3)  (3,3)  (4,3)  (5,3)  (6,3)
    ///         [2]    [2]
    ///  3{3}   4{5}     -      -      -      -      -
    ///
    /// (0,4)  (1,4)  (2,4)  (3,4)  (4,4)  (5,4)  (6,4)
    ///  4{4}   5{5}   6{6}      -      -      -      -
    ///
    /// (0,5)  (1,5)  (2,5)  (3,5)  (4,5)  (5,5)  (6,5)
    ///  5{5}   6{6}      -      -      -      -      -
    ///
    /// (0,6)  (1,6)  (2,6)  (3,6)  (4,6)  (5,6)  (6,6)
    ///  6{6}      -      -      -      -      -      -
    ///

    test('test 1', () {
      astar.resetNodes();
      final path = (astar.findSteps(start: const (x: 0, y: 0), steps: 6));
      path.sort((a, b) => a.y.compareTo(b.y));
      path.sort((a, b) => a.x.compareTo(b.x));
      path.sort((a, b) => a.distance.compareTo(b.distance));
      print(
          'path:\n${path.map((i) => '(${i.x}_${i.y}):distance ${i.distance},').join('\n')}');
      expect(path.length, 16); // Check number of cols
    });

    /// (x,y)
    /// (0,0)  (1,0)  (2,0)  (3,0)  (4,0)  (5,0)  (6,0)
    ///         [2]    [2]    [2]
    ///  2{3}   1{2}   start  1{2}   2{3}   3{4}   4{5}
    ///
    /// (0,1)  (1,1)  (2,1)  (3,1)  (4,1)  (5,1)  (6,1)
    ///         [3]    [3]
    ///  3{4}   2{5}   1{3}   3{3}   3{4}   4{5}   5{6}
    ///
    /// (0,2)  (1,2)  (2,2)  (3,2)  (4,2)  (5,2)  (6,2)
    ///         [2]    [2]    [5]
    ///  4{5}    -     4{5}    -     4{5}   5{6}     -
    ///
    /// (0,3)  (1,3)  (2,3)  (3,3)  (4,3)  (5,3)  (6,3)
    ///         [2]    [2]
    ///  5{6}    -      -      -     5{6}    -      -
    ///
    /// (0,4)  (1,4)  (2,4)  (3,4)  (4,4)  (5,4)  (6,4)
    ///   -    -     -       -      -      -      -
    ///
    /// (0,5)  (1,5)  (2,5)  (3,5)  (4,5)  (5,5)  (6,5)
    ///   -      -      -      -      -      -      -
    ///
    /// (0,6)  (1,6)  (2,6)  (3,6)  (4,6)  (5,6)  (6,6)
    ///   -      -      -      -      -      -      -
    ///

    test('test 2', () {
      astar.resetNodes();
      final path = (astar.findSteps(start: const (x: 2, y: 0), steps: 6));
      path.sort((a, b) => a.y.compareTo(b.y));
      path.sort((a, b) => a.x.compareTo(b.x));
      path.sort((a, b) => a.distance.compareTo(b.distance));
      print(
          'path:\n${path.map((i) => '(${i.x}_${i.y}):distance ${i.distance},').join('\n')}');
      expect(path.length, 19); // Check number of cols
    });

    //----------------
  });
}
