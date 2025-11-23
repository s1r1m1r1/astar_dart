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
  final start = (x: 0, y: 0);

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

    array2d.elementAt(start.x, start.y).target = Target.player;

    _setObstacles();
  }

  void _setObstacles() {
    // Example Hex Obstacles (Customize as needed)
    array2d.elementAt(3, 3).ground = GroundType.barrier;
    array2d.elementAt(4, 4).ground = GroundType.barrier;
    array2d.elementAt(5, 3).ground = GroundType.barrier;
    array2d.elementAt(2, 4).ground = GroundType.water;
    array2d.elementAt(7, 2).ground = GroundType.forest;
  }

  Future<void> _calculatePath(Floor floor) async {
    debugPrint("calculate start ${floor.x} ${floor.y}");
    final astar = AStarHex(
      // Manhattan heuristic is still ok for hex grid, but you can explore others.
      rows: array2d.width,
      columns: array2d.height,
      gridBuilder: (int x, int y) {
        final floor = array2d.elementAt(x, y);
        return ANode(
            x: x,
            y: y,
            neighbors: [],
            weight: switch (floor.ground) {
              GroundType.field => 1,
              GroundType.water => 7,
              GroundType.forest => 10,
              GroundType.barrier => 1000,
            });
      },
    );
    astar.addNeighbors();

    debugPrint("calculate start 2");
    final path = await Future.value(
        astar.findPath(start: start, end: (x: floor.x, y: floor.y)));

    debugPrint("calculate start 3");
    for (var a in array2d.array) {
      a.isPath = false;
    }
    if (path.isNotEmpty) {
      for (var p in path) {
        array2d.elementAt(p.x, p.y)
          ..isPath = true
          ..update();
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: array2d.width * 200,
                    height: array2d.height * 200.0,
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
                                floor: array2d.elementAt(x, y),
                                onTap: (floor) => _calculatePath(floor),
                                color: switch (array2d.elementAt(x, y)) {
                                  Floor(:final x, :final y)
                                      when x == start.x && y == start.y =>
                                    Colors.purple,
                                  Floor(isPath: true) => Colors.grey,
                                  Floor(ground: GroundType.field) =>
                                    Colors.greenAccent,
                                  Floor(ground: GroundType.water) =>
                                    Colors.lightBlue,
                                  Floor(ground: GroundType.forest) =>
                                    Colors.green[700],
                                  Floor(ground: GroundType.barrier) =>
                                    Colors.black,
                                }!,
                              ),
                            )
                      ],
                    ),
                  ),
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
    required this.color,
  });
  final Floor floor;
  final Color color;
  final Function(Floor floor) onTap;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: HexTileClipper(),
      child: GestureDetector(
        onTap: () {
          onTap(floor);
        },
        child: ListenableBuilder(
            listenable: floor,
            builder: (context, _) {
              return CustomPaint(
                painter: HexTilePainter(color: color),
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
              );
            }),
      ),
    );
  }
}

class HexTileClipper extends CustomClipper<Path> {
  @override
  getClip(Size size) {
    return Path()
      ..moveTo(0, (size.height * 0.25))
      ..lineTo((size.width / 2), 0)
      ..lineTo(size.width, (size.height * 0.25))
      ..lineTo(size.width, (size.height * 0.75))
      ..lineTo((size.width / 2), size.height)
      ..lineTo(0, (size.height * 0.75))
      ..lineTo(0, (size.height * 0.25))
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return false;
  }
}

class HexTilePainter extends CustomPainter {
  final Color color;

  HexTilePainter({required this.color});
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

    final paint = Paint();
    paint
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
    paint
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
