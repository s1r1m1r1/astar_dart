import 'package:a_star_algorithm/a_star_algorithm.dart' as astar2;
import 'package:astar_dart/astar_dart.dart';
import 'package:a_star/a_star.dart' as astar3;
import 'package:benchmark_harness/benchmark_harness.dart';

///
///```bash
/// cd benchmarks;
/// dart run lib/main.dart;
///```
/// dart run lib/main.dart
void main() {
  // too slow
  AstarTest2Benchmark(withDiagonal: false, size: 32).report();
  // maybe ok
  AstarTest2Benchmark(withDiagonal: true, size: 32).report();

  // my astar
  AStarBenchmark(algorithm: Names.algorithmManhattan, size: 32).report();
  AStarBenchmark(algorithm: Names.algorithmHex, size: 32).report();
  AStarBenchmark(algorithm: Names.algorithmEuclidean, size: 32).report();

  // so simple , for empty world, is this useful?
  AstarTest3Benchmark().report();
}

enum Names {
  algorithmHex,
  algorithmManhattan,
  algorithmEuclidean,
}

class AStarBenchmark extends BenchmarkBase {
  final Names algorithm;
  late AstarGrid astar;
  final int size;

  AStarBenchmark({required this.algorithm, required this.size})
      : super(algorithm.name);

  @override
  void run() {
    switch (algorithm) {
      case Names.algorithmHex:
        astar = AStarHex(
            rows: size,
            columns: size,
            gridBuilder: (int x, int y) {
              return ANode(x: x, y: y, neighbors: []);
            });
      case Names.algorithmManhattan:
        astar = AStarManhattan(
          rows: size,
          columns: size,
          gridBuilder: (x, y) {
            if (x == 6 && y > 1) {
              return ANode(x: x, y: y, neighbors: [], isBarrier: true);
            }
            if (x == 18 && y < 30) {
              return ANode(x: x, y: y, neighbors: [], isBarrier: true);
            }
            return ANode(x: x, y: y, neighbors: []);
          },
        );
      case Names.algorithmEuclidean:
        astar = AStarEuclidean(
          rows: size,
          columns: size,
          gridBuilder: (int x, int y) {
            if (x == 6 && y >= 0 && y < 10 && y > 12) {
              return ANode(x: x, y: y, neighbors: [], isBarrier: true);
            }
            if (x == 18 && y < 30) {
              return ANode(x: x, y: y, neighbors: [], isBarrier: true);
            }

            return ANode(x: x, y: y, neighbors: []);
          },
        );
    }
    const start = (x: 0, y: 0);
    final end = (x: size - 1, y: size - 1);
    astar.addNeighbors();

    // final path =
    astar.findPath(start: start, end: end);
  }
}

class AstarTest2Benchmark extends BenchmarkBase {
  final int size;
  final bool withDiagonal;
  late astar2.AStar astar;

  AstarTest2Benchmark({
    this.size = 50,
    this.withDiagonal = false,
  }) : super("a_star_algorithm: withDiagonal: $withDiagonal");

  @override
  void run() {
    final start = (0, 0);
    final end = (size - 1, size - 1);
    astar = astar2.AStar(
      rows: size,
      columns: size,
      start: start,
      end: end,
      barriers: [
        ...List.generate(10, (x) => (x, 6)),
        ...List.generate(20, (x) => (31 - x, 6)),
        ...List.generate(30, (x) => (31 - x, 18))
      ],
      withDiagonal: withDiagonal,
    );
    // final result =
    astar.findThePath();
  }
}

class AstarTest3Benchmark extends BenchmarkBase {
  AstarTest3Benchmark() : super('Astar 3 test');

  @override
  void run() {
    const settings = CoordinatesState(0, 0);
    final result = astar3.aStar<CoordinatesState>(settings);
    if (result == null) {
      print("No path");
      return;
    }
    // final path =
    result.reconstructPath();
  }
}

class CoordinatesState extends astar3.AStarState<CoordinatesState> {
  final int goalX;
  final int goalY;

  final int x;
  final int y;

  const CoordinatesState(this.x, this.y,
      {super.depth = 0, this.goalX = 32, this.goalY = 32});

  @override
  Iterable<CoordinatesState> expand() => [
        CoordinatesState(x, y + 1, depth: depth + 1), // down
        CoordinatesState(x, y - 1, depth: depth + 1), // up
        CoordinatesState(x + 1, y, depth: depth + 1), // right
        CoordinatesState(x - 1, y, depth: depth + 1), // left
      ];

  @override
  double heuristic() => ((goalX - x).abs() + (goalY - y).abs()).toDouble();

  @override
  String hash() => "($x, $y)";

  @override
  bool isGoal() => x == goalX && y == goalY;
}
