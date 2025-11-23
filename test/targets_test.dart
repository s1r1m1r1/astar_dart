import 'package:astar_dart/astar_dart.dart';
import 'package:test/test.dart';

void main() {
  late final AStarManhattan astar;
  setUpAll(() {
    astar = AStarManhattan(rows: 5, columns: 5);
    astar.setBarrier(
      x: 0,
      y: 2,
      isBarrier: true,
    );
    astar.addNeighbors();
  });
  group('find targets', () {
    test('test not targets , no path', () {
      astar.resetNodes();
      final targets = astar.findTargets(start: const (
        x: 0,
        y: 0
      ), targets: [
        const (x: 3, y: 0),
        const (x: 3, y: 1),
        const (x: 3, y: 2),
        const (x: 4, y: 0)
      ], steps: 3);

      expect(targets.length, 2); // Check number of cols
    });

    ///
    /// (0,0)  (1,0)  (2,0)  (3,0)  (4,0)
    /// start    1      2      3    [ t ]
    ///
    /// (0,1)  (1,1)  (2,1)  (3,1)  (4,1)
    /// [ t ]    2     [t]     ---    ---
    ///
    /// (0,2)  (1,2)  (2,2)  (3,2)  (4,2)
    ///  xx      3     [ t ]   ---    --
    ///
    /// (0,3)  (1,3)  (2,3)  (3,3)  (4,3)
    ///  ---   [ t ]   -t-    -t-   ---
    ///
    /// (0,4)  (1,4)  (2,4)  (3,4)  (4,4)
    ///  ---    ---    ---    ---    ---
    ///
    ///
    test('test 2  ', () {
      astar.resetNodes();
      final s = astar.findTargets(start: const (
        x: 0,
        y: 0
      ), targets: [
        // found
        const (x: 0, y: 1),
        const (x: 2, y: 1),
        const (x: 1, y: 3),
        const (x: 2, y: 2),
        const (x: 4, y: 0),
        // not found
        const (x: 2, y: 3),
        const (x: 3, y: 3),
      ], steps: 3);
      expect(s.length, 5);
      expect(s.where((i) => i.distance == 1 && i.x == 0 && i.y == 1).length, 1);
      expect(s.where((i) => i.distance == 4 && i.x == 4 && i.y == 0).length, 1);
    });

    ///
    /// (0,0)  (1,0)  (2,0)  (3,0)  (4,0)
    /// start    1      2      3    [ t ]
    ///
    /// (0,1)  (1,1)  (2,1)  (3,1)  (4,1)
    /// [ t ]    2     [t]     ---    ---
    ///
    /// (0,2)  (1,2)  (2,2)  (3,2)  (4,2)
    ///  xx      3     [ t ]   ---    --
    ///
    /// (0,3)  (1,3)  (2,3)  (3,3)  (4,3)
    ///  ---   [ t ]   -t-    -t-   ---
    ///
    /// (0,4)  (1,4)  (2,4)  (3,4)  (4,4)
    ///  ---    ---    ---    ---    ---
    ///
    ///
    test('test 2  ', () {
      astar.resetNodes();
      final s = astar.findTargets(start: const (
        x: 0,
        y: 0
      ), targets: [
        // found
        const (x: 0, y: 1),
        const (x: 2, y: 1),
        const (x: 1, y: 3),
        const (x: 2, y: 2),
        const (x: 4, y: 0),
        // not found
        const (x: 2, y: 3),
        const (x: 3, y: 3),
      ], steps: 3);
      expect(s.length, 5);
      expect(s.where((i) => i.distance == 1 && i.x == 0 && i.y == 1).length, 1);
      expect(s.where((i) => i.distance == 4 && i.x == 4 && i.y == 0).length, 1);
    });

    ///
    /// (0,0)  (0,1)  (0,2)  (0,3)  (0,4)
    ///   -    -        t    --      t
    ///
    /// (1,0)  (1,1)  (1,2)  (1,3)  (1,4)
    ///  -       -      -    ---    ---
    ///
    /// (2,0)  (2,1)  (2,2)  (2,3)  (2,4)
    ///  xx      -      t    ---      4
    ///
    /// (3,0)  (3,1)  (3,2)  (3,3)  (3,4)
    ///   3    [t]    [t]    [t]     3
    ///
    /// (4,0)  (4,1)  (4,2)  (4,3)  (4,4)
    ///   2      1    start    1      2
    ///
    ///
    test('test  3 targets blocked path to next one ', () {
      astar.resetNodes();
      final targets = astar.findTargets(start: const (
        x: 4,
        y: 2
      ), targets: [
        // found
        const (x: 3, y: 1),
        const (x: 3, y: 2),
        const (x: 3, y: 3),
        // blocked
        const (x: 2, y: 2),
        // not found
        const (x: 0, y: 2),
        const (x: 0, y: 4),
      ], steps: 4);

      expect(targets.length, 3); // Check number of cols
    });
  });

// (0,0)  (1,0)  (2,0)  (3,0)  (4,0)
//   start  -      -      -      -

// (0,1)  (1,1)  (2,1)  (3,1)  (4,1)
//   -      -      -      -      -

// (0,2)  (1,2)  (2,2)  (3,2)  (4,2)
//   xx     t      -      -      -

// (0,3)  (1,3)  (2,3)  (3,3)  (4,3)
//   -      -      -      -      -

// (0,4)  (1,4)  (2,4)  (3,4)  (4,4)
//   -      -      -      -      t

  test('find targets around a barrier', () {
    astar.resetNodes();
    final targets = astar.findTargets(
        start: const (x: 0, y: 0),
        targets: [const (x: 1, y: 2), const (x: 4, y: 4)],
        steps: 8);

    expect(targets.length, 2);
    expect(targets.firstWhere((p) => p.x == 1 && p.y == 2).distance, 3);
    expect(targets.firstWhere((p) => p.x == 4 && p.y == 4).distance, 8);
  });
}
