import 'dart:math';

import 'package:a_star_algorithm/a_star_algorithm.dart' as astar2;
import 'package:astar_dart/astar_dart.dart';
import 'package:a_star/a_star.dart' as astar3;
import 'package:benchmark_harness/benchmark_harness.dart';

// dart run main.dart
void main() {
  //------ size 50
  AStarBenchmark(algorithm: Names.algorithmHex, size: 256).report();
  AStarBenchmark(algorithm: Names.algorithmManhattan, size: 256).report();
  AStarBenchmark(algorithm: Names.algorithmEuclidean, size: 256).report();
  // too slow
  // AstarTest2Benchmark(withDiagonal: false,size: 50).report();
  AstarTest2Benchmark(withDiagonal: true, size: 256).report();
  AstarTest3Benchmark().report();
}

enum Names {
  algorithmHex,
  algorithmManhattan,
  algorithmEuclidean,
}

class AStarBenchmark extends AsyncBenchmarkBase {
  final Names algorithm;
  late AstarGrid astar;
  final int size;

  AStarBenchmark({required this.algorithm, required this.size})
      : super(algorithm.name);

  @override
  Future<void> run() async {
    switch (algorithm) {
      case Names.algorithmHex:
        astar = AStarHex(
            rows: size,
            columns: size,
            gridBuilder: (int x, int y) {
              return ANode(x: x, y: y, neighbors: []);
            });
        break;
      case Names.algorithmManhattan:
        astar = AStarManhattan(
          rows: size,
          columns: size,
          gridBuilder: (x, y) {
            if (x == 3 && [0, 1, 2, 8].contains(y)) {
              return ANode(x: x, y: y, neighbors: [], barrier: Barrier.block);
            }
            if (x == 8 && [3, 5, 9].contains(y)) {
              return ANode(x: x, y: y, neighbors: [], barrier: Barrier.block);
            }
            return ANode(x: x, y: y, neighbors: []);
          },
        );
        break;
      case Names.algorithmEuclidean:
        astar = AStarEuclidean(
            rows: size,
            columns: size,
            gridBuilder: (int x, int y) {
              if (x == 3 && [0, 1, 2, 7, 8].contains(y)) {
                return ANode(x: x, y: y, neighbors: [], barrier: Barrier.block);
              }
              if (x == 8 && [3, 5, 6, 8, 9].contains(y)) {
                return ANode(x: x, y: y, neighbors: [], barrier: Barrier.block);
              }
              return ANode(x: x, y: y, neighbors: []);
            });
        break;
    }
    const start = (x: 0, y: 0);
    final ({int x, int y}) end = (x: size - 1, y: size - 1);
    astar.addNeighbors();
    final path = await astar.findPath(
        start: start,
        end: end,
        doneList: (list) {
          // print('Done LENGTH ${list.length}');
        });
    // print('PATH LENGTH ${path.length}');
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
        ...List.generate(size - 5, (i) => (3, i)),
        ...List.generate(size - 3, (i) => (5, i + 2)),
      ],
      withDiagonal: withDiagonal,
    );
    astar.findThePath();
  }
}

class AstarTest3Benchmark extends BenchmarkBase {
  AstarTest3Benchmark() : super('Astar 3 test');

  @override
  void run() {
    final settings = CoordinatesState(0, 0);
    final result = astar3.aStar<CoordinatesState>(settings);
    if (result == null) {
      print("No path");
      return;
    }
    final path = result.reconstructPath();
  }
}

class CoordinatesState extends astar3.AStarState<CoordinatesState> {
  final int goalX;
  final int goalY;

  final int x;
  final int y;

  const CoordinatesState(this.x, this.y,
      {super.depth = 0, this.goalX = 256, this.goalY = 256});

  @override
  Iterable<CoordinatesState> expand() => [
        CoordinatesState(x, y + 1, depth: depth + 1), // down
        CoordinatesState(x, y - 1, depth: depth + 1), // up
        CoordinatesState(x + 1, y, depth: depth + 1), // right
        CoordinatesState(x - 1, y, depth: depth + 1), // left

        // CoordinatesState(x + 1, y + 1, depth: depth + 1), // right down
        // CoordinatesState(x - 1, y - 1, depth: depth + 1), //left up
        // CoordinatesState(x + 1, y - 1, depth: depth + 1), // right up
        // CoordinatesState(x - 1, y + 1, depth: depth + 1), // left down
      ];

  @override
  double heuristic() => ((goalX - x).abs() + (goalY - y).abs()).toDouble();

  @override
  String hash() => "($x, $y)";

  @override
  bool isGoal() => x == goalX && y == goalY;
}
