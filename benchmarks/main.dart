import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:benchmarking/benchmarking.dart';

void main() {
  _runBenchmark(
    'PrimitiveEquatable',
    (index) => _createAndFindPath(),
  );
}

Future<void> _createAndFindPath() async {
  final size = 100; // Example grid size for benchmark. Adjust as needed.
  final Point<int> start;
  final Point<int> end;
  final astar = AStarManhattan(rows: size, columns: size);
  astar.calculateGrid();
  // Add some barriers (optional). Adjust density as needed.
  final random = Random();
  for (var i = 0; i < size * size * 0.2; ++i) {
    // 20% barriers
    astar.setBarrier(BarrierPoint(random.nextInt(size), random.nextInt(size),
        barrier: Barrier.block));
  }

  start = const Point(0, 0);
  end = Point(size - 1, size - 1);
  // While this is a widget test, the AStarManhattan logic itself doesn't involve widgets.
  // We can still use it to benchmark within a Flutter test environment.
  await astar.findPath(start: start, end: end); // Benchmark the actual code.

  // final filePath = await _getResultsFilePath();
  // final resultsString = 'astar_dart: v:${packageVersion}'
  //     'AStarManhattan.findPath execution time: ${stopwatch.elapsedMicroseconds} microseconds\n----------------------------------\n ';
  // await _saveResultsToFile(resultsString, filePath);
}

void _runBenchmark(String name, Object Function(int index) create) {
  const poolSize = 100;
  final pool = List.generate(poolSize, create);
  final poolA = [...pool]..shuffle();
  final poolB = [...pool]..shuffle();
  bool? result; // so that the loop isn't optimized out
  syncBenchmark(name, () {
    for (var i = 0; i < poolSize; i++) {
      result = poolA[i] == poolB[i];
    }
  }).report(units: poolSize);
  assert(result != null, 'result should be defined.');
}
