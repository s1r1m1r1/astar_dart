// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:astar_dart/astar_dart.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GridExample(),
    );
  }
}

class GridExample extends StatefulWidget {
  const GridExample({super.key});

  @override
  State<GridExample> createState() => _GridExampleState();
}

class _GridExampleState extends State<GridExample> {
  late ValueNotifier<bool> updater;
  late final Array2d<Floor> array2d;
  ({int x, int y}) start = (x: 0, y: 0);
  ({int x, int y}) end = (x: 9, y: 9);

  @override
  void initState() {
    super.initState();
    updater = ValueNotifier(false);
    _initializeGrid();
  }

  void _initializeGrid() {
    array2d = Array2d<Floor>(10, 10, valueBuilder: (x, y) {
      return Floor(
        x: x,
        y: y,
        ground: GroundType.field,
        target: Target.none,
      );
    });

    array2d[start.x][start.y].target = Target.player;
    array2d[end.x][end.y].target = Target.enemy;

    _setObstacles();
  }

  void _setObstacles() {
    // Example Hex Obstacles (Customize as needed)
    array2d[3][3].ground = GroundType.barrier;
    array2d[4][4].ground = GroundType.barrier;
    array2d[5][3].ground = GroundType.barrier;
    array2d[2][4].ground = GroundType.water;
    array2d[7][2].ground = GroundType.forest;
  }

  Future<void> _calculatePath(Floor flor) async {
    final astar = AStarManhattan(
      // Manhattan heuristic is still ok for hex grid, but you can explore others.
      rows: 10,
      columns: 10,
    )..setPoints([
        ...array2d.array.expand((row) {
          return row.map((floor) => WeightedPoint(floor.x, floor.y,
              weight: switch (floor.ground) {
                GroundType.field => 1,
                GroundType.water => 7,
                GroundType.forest => 10,
                GroundType.barrier => 100,
              }));
        })
      ]);

    final path = await astar.findPath(start: start, end: end);

    array2d.forEach((floor, x, y) => floor.isPath = false);
    if (path != null) {
      for (var p in path) {
        array2d[p.x][p.y].isPath = true;
      }
    } else {
      debugPrint("No path found!");
    }

    setState(() {
      updater.value = !updater.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(fontSize: 8),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('A* Hex Pathfinding Demo 2'),
        ),
        body: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50.0),
              child: SizedBox(
                height: 30 * 100.0,
                width: 30 * 100.0,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    for (var x = 0; x < 10; x++)
                      for (var y = 0; y < 10; y++)
                        Positioned(
                          left: (x * 100.0) + (y * 50),
                          top: y * 75.0,
                          height: 100,
                          width: 100,
                          child: FloorItemWidget(
                            floor: array2d[x][y],
                            onTap: (floor) => _calculatePath(floor),
                          ),
                        )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FloorItemWidget extends StatelessWidget {
  const FloorItemWidget({
    super.key,
    required this.floor,
    required this.onTap,
  });
  final Floor floor;
  final Function(Floor floor) onTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: floor,
      builder: (context, _) {
        return ClipRRect(
          child: CustomPaint(
            painter: HexTilePainter(floor: floor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                Text('x: ${floor.x}, y: ${floor.y}'),
                Text(
                  "weight: ${switch (floor.ground) {
                    GroundType.field => '1',
                    GroundType.water => '7',
                    GroundType.forest => '10',
                    GroundType.barrier => 'x',
                  }}",
                ),
                // Row(
                //   mainAxisSize: MainAxisSize.min,
                //   children: [
                //     // SizedBox(width: 32),
                //     // Icon(
                //     //   switch (floor.ground) {
                //     //     GroundType.field => Icons.grass,
                //     //     GroundType.water => Icons.water,
                //     //     GroundType.forest => Icons.forest,
                //     //     GroundType.barrier => Icons.block,
                //     //   },
                //     //   color: Colors.black,
                //     //   size:10.0,
                //     // ),
                //     SizedBox(width: 32),

                //   ],
                // ),
                // SizedBox(height: 32),
                // Text(
                //   switch (floor.target) {
                //     Target.player => 'PLAYER',
                //     Target.enemy => 'ENEMY',
                //     Target.none => '',
                //   },
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class HexTilePainter extends CustomPainter {
  final Floor floor;

  HexTilePainter({required this.floor});
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, (size.height * 0.25))
      ..lineTo((size.width / 2), 0)
      ..lineTo(size.width, (size.height * 0.25))
      ..lineTo(size.width, (size.height * 0.75))
      ..lineTo((size.width / 2), size.height)
      ..lineTo(0, (size.height * 0.75))
      ..lineTo(0, (size.height * 0.25));
    // ..lineTo(0, (size.height * 0.25));

    final fillColor = switch (floor.ground) {
      _ when floor.isPath => Colors.grey.withOpacity(0.5),
      GroundType.field => Colors.green[200],
      GroundType.water => Colors.cyanAccent,
      GroundType.forest => Colors.green[800],
      GroundType.barrier => Colors.red,
    };
    final paint = Paint();
    paint
      ..color = fillColor!
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
    paint
      ..color = Colors.black!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
