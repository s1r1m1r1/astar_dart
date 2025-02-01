import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:astar_dart/astar_dart.dart';

void main() {
  runApp(MaterialApp(
    home: ResultPage(),
  ));
}

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String benchMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: () async{
        try{
        await createAndFindPath();
        }catch(error){
          benchMessage = error.toString();
        }
      }),
      body: Center(
        child: Text(benchMessage),
      ),
    );
  }

  FutureOr<void> createAndFindPath() async {
    final size = 100; // Example grid size for benchmark. Adjust as needed.
    final Point<int> start;
    final Point<int> end;
    final stopwatch = Stopwatch();
    stopwatch.start();
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
    stopwatch.stop();

    final filePath = await _getResultsFilePath();
    final resultsString = 'astar_dart: v:${packageVersion}'
        'AStarManhattan.findPath execution time: ${stopwatch.elapsedMicroseconds} microseconds\n----------------------------------\n ';
    await _saveResultsToFile(resultsString, filePath);
    setState(() {
      benchMessage = resultsString;
    });
  }
}

Future<String> _getResultsFilePath() async {
  final currentDir = Directory.current; // Get the project directory
  final resultsDir = Directory(path.join(currentDir.path, 'test/bench',
      'bench_results')); // Create 'benchmark_results' directory if it doesn't exist
  await resultsDir.create(recursive: true);
  final filePath = path.join(resultsDir.path, 'benchmark_results.txt');
  return filePath;
}

Future<void> _saveResultsToFile(String results, String filePath) async {
  final file = File(filePath);
  await file.writeAsString(results,
      mode: FileMode.append); // Append to the file
}
