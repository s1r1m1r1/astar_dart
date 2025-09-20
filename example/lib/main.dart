// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Astar  example',
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
  IconData lastTapped = Icons.notifications;
  late final Array2d<Floor> array2d;

  @override
  void initState() {
    super.initState();
    updater = ValueNotifier(false);
    array2d = Array2d<Floor>(10, 10, valueBuilder: (x, y) {
      if ((x >= 1 && x < 4 && y == 1) ||
          (x == 1 && y == 2) ||
          (x >= 1 && x < 4 && y == 3)) {
        return Floor(
          x: x,
          y: y,
          ground: GroundType.water,
          target: Target.none,
        );
      } else if (x >= 4 && x < 8 && y >= 5 && y < 9) {
        return Floor(
          x: x,
          y: y,
          ground: GroundType.forest,
          target: Target.none,
        );
      } else if (x >= 2 && x < 4 && y >= 4 && y < 6) {
        return Floor(
          x: x,
          y: y,
          ground: GroundType.barrier,
          target: Target.none,
        );
      } else if (x == 0 && y == 0) {
        return Floor(
          x: x,
          y: y,
          ground: GroundType.field,
          target: Target.player,
        );
      } else {
        return Floor(
          x: x,
          y: y,
          ground: GroundType.field,
          target: Target.none,
        );
      }
    });
  }

  Future<void> _updateFloor(Floor floor) async {
    debugPrint('updateFloor target x:${floor.x}, y: ${floor.y}');
    final astar = AStarManhattan(
      rows: 10,
      columns: 10,
      gridBuilder: (x, y) {
        final floor = array2d[x][y];
        return ANode(
            x: x,
            y: y,
            neighbors: [],
            weight: switch (floor.ground) {
              GroundType.field => 1,
              GroundType.water => 7,
              GroundType.forest => 10,
              GroundType.barrier => 1,
            },
            isBarrier: switch (floor.ground) {
              GroundType.field ||
              GroundType.water ||
              GroundType.forest =>
                false,
              GroundType.barrier => true,
            });
      },
    );
    astar.addNeighbors();

    final path =
        await Future.value(astar.findPath(start: Point(0, 0), end: floor));
    array2d.forEach((floor, x, y) => floor
      ..isPath = false
      ..update());
    for (var p in path) {
      array2d[p.x][p.y]
        ..isPath = true
        ..update();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
      child: Center(
        child: InteractiveViewer(
          panAxis: PanAxis.free,
          boundaryMargin: const EdgeInsets.all(200),
          minScale: 0.1,
          maxScale: 1.6,
          child: Wrap(
            direction: Axis.horizontal,
            runSpacing: 2,
            spacing: 2,
            children: [
              for (var x = 0; x < 10; x++)
                for (var y = 0; y < 10; y++)
                  FloorItemWidget(
                    floor: array2d[x][y],
                    onTap: (floor) async {
                      await _updateFloor(floor);
                    },
                  )
            ],
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
        return Material(
          type: MaterialType.transparency,
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: 100, minHeight: 100, maxWidth: 100, minWidth: 100),
            child: Ink(
              decoration: BoxDecoration(
                  color: switch (floor.ground) {
                    _ when floor.isPath => Colors.grey,
                    GroundType.field => Colors.green[200],
                    GroundType.water => Colors.cyanAccent,
                    GroundType.forest => Colors.green[700],
                    GroundType.barrier => Colors.red[700],
                  },
                  border: Border.all(color: Colors.black, width: 3.0)),
              child: InkWell(
                onTap: () {
                  onTap(floor);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('x: ${floor.x}, y: ${floor.y}'),
                    SizedBox(height: 2),
                    Text(
                      "weight: ${switch (floor.ground) {
                        GroundType.field => '1',
                        GroundType.water => '7',
                        GroundType.forest => '10',
                        GroundType.barrier => 'x',
                      }}",
                    ),
                    SizedBox(height: 4),
                    Icon(
                      switch (floor.ground) {
                        GroundType.field => Icons.grass,
                        GroundType.water => Icons.water,
                        GroundType.forest => Icons.forest,
                        GroundType.barrier => Icons.block,
                      },
                      color: Colors.black,
                      size: 20.0,
                    ),
                    SizedBox(height: 2),
                    Text(
                      switch (floor.target) {
                        Target.player => 'PLAYER',
                        Target.enemy => 'ENEMY',
                        Target.none => '',
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// --------------------- Create world --------------------------
enum GroundType {
  field,
  water,
  forest,
  barrier,
}

enum Target {
  player,
  enemy,
  none,
}

class Floor extends Point<int> with ChangeNotifier {
  Floor({
    required int x,
    required int y,
    required this.target,
    required this.ground,
    this.isPath = false,
  }) : super(x, y);

  bool isPath;

  GroundType ground;

  Target target;

  void update() {
    notifyListeners();
  }

  factory Floor.wrong() => Floor(
        x: -1,
        y: -1,
        ground: GroundType.field,
        target: Target.none,
        isPath: false,
      );
}
