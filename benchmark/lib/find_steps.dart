import 'package:astar_dart/astar_dart.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

///
///```bash
/// cd benchmarks;
/// dart run main.dart;
///```
/// dart run main.dart
void main() {
  // my astar
  AStarBenchmark(algorithm: Names.algorithmManhattan, size: 32).report();
  AStarBenchmark(algorithm: Names.algorithmHex, size: 32).report();
  AStarBenchmark(algorithm: Names.algorithmEuclidean, size: 32).report();

  // AStarBenchmark(algorithm: Names.algorithmManhattan, size: 32).report();
  // AStarBenchmark(algorithm: Names.algorithmHex, size: 32).report();
  // AStarBenchmark(algorithm: Names.algorithmEuclidean, size: 32).report();
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
            return ANode(x: x, y: y, neighbors: []);
          },
        );
      case Names.algorithmEuclidean:
        astar = AStarEuclidean(
          rows: size,
          columns: size,
          gridBuilder: (int x, int y) {
            return ANode(x: x, y: y, neighbors: []);
          },
        );
    }
    const start = (x: 0, y: 0);
    astar.addNeighbors();

    // final path =
    astar.findSteps(start: (x: start.x, y: start.y), steps: 15);
  }
}
