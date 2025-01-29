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
    )
      ..setPoints([
        ...array2d.array.expand((row) {
          return row.map((floor) => WeightedPoint(floor.x, floor.y,
              weight: switch (floor.ground) {
                GroundType.field => 1,
                GroundType.water => 7,
                GroundType.forest => 10,
                GroundType.barrier => 1,
              }));
        })
      ])
      ..setBarriers([
        ...array2d.array.expand((row) {
          return row.map((floor) => floor.ground == GroundType.barrier
              ? BarrierPoint(floor.x, floor.y, barrier: Barrier.block)
              : BarrierPoint(
                  floor.x,
                  floor.y,
                  barrier: Barrier.pass,
                ));
        })
      ])
      ..calculateGrid();
    final path = await astar.findPath(
        start: Point<int>(0, 0), end: Point<int>(floor.x, floor.y));
    array2d.forEach((floor, x, y) => floor
      ..isPath = false
      ..update());
    for (var p in path) {
      array2d[p.x][p.y]
        ..isPath = true
        ..update();
    }
  }

  Future<void> _updateMenu(Floor floor) async {
    final astar = AStarManhattan(
      rows: 10,
      columns: 10,
    )
      ..setPoints([
        ...array2d.array.expand((row) {
          return row.map((floor) => WeightedPoint(floor.x, floor.y,
              weight: switch (floor.ground) {
                GroundType.field => 1,
                GroundType.water => 7,
                GroundType.forest => 10,
                GroundType.barrier => 1,
              }));
        })
      ])
      ..setBarriers([
        ...array2d.array.expand((row) {
          return row.map((floor) => floor.ground == GroundType.barrier
              ? BarrierPoint(floor.x, floor.y, barrier: Barrier.block)
              : BarrierPoint(
                  floor.x,
                  floor.y,
                  barrier: Barrier.pass,
                ));
        })
      ])
      ..calculateGrid();
    final path = await astar.findPath(
        start: Point<int>(0, 0), end: Point(floor.x, floor.y));
    debugPrint("PATH ${path.length} ${updater.value}");
    array2d.forEach((floor, x, y) => floor.isPath = false);
    for (var p in path) {
      array2d[p.x][p.y].isPath = true;
    }
    setState(() {
      updater.value = !(updater.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 100.0),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints.tightFor(height: 10 * 100, width: 10 * 100),
              child: Flow(
                delegate: MyFlowDelegate(updater: updater),
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
        ),
      ),
    );
  }
}

class MyFlowDelegate extends FlowDelegate {
  MyFlowDelegate({required this.updater})
      : super(
          repaint: updater,
        );

  final ValueNotifier<bool> updater;

  @override
  bool shouldRepaint(MyFlowDelegate oldDelegate) {
    return updater != oldDelegate.updater;
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    final startPoint = Size(0, 0);
    for (int i = 0; i < context.childCount; ++i) {
      final y = i % 10;
      final x = i ~/ 10;

      context.paintChild(
        i,
        transform: Matrix4.translationValues(-startPoint.width + (x * 100.0),
            -startPoint.height + (y * 100.0), 0),
      );
    }
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('x: ${floor.x}, y: ${floor.y}'),
                        SizedBox(width: 32),
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
                        SizedBox(width: 32),
                        Text(
                          "weight: ${switch (floor.ground) {
                            GroundType.field => '1',
                            GroundType.water => '7',
                            GroundType.forest => '10',
                            GroundType.barrier => 'x',
                          }}",
                        )
                      ],
                    ),
                    SizedBox(height: 32),
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

class Floor with ChangeNotifier {
  Floor({
    required int x,
    required int y,
    required Target target,
    required GroundType ground,
    bool isPath = false,
  }) {
    _isPath = isPath;
    _ground = ground;
    _target = target;
    _x = x;
    _y = y;
  }
  late int _x;
  set x(int value) {
    _x = value;
  }

  int get x => _x;

  late int _y;
  set y(int value) {
    _y = value;
  }

  int get y => _y;

  late bool _isPath;
  set isPath(bool value) {
    _isPath = value;
  }

  late GroundType _ground;
  set ground(GroundType value) {
    _ground = value;
  }

  GroundType get ground => _ground;

  late Target _target;
  set target(Target value) {
    _target = value;
  }

  void update() {
    notifyListeners();
  }

  Target get target => _target;

  bool get isPath => _isPath;

  factory Floor.wrong() => Floor(
        x: -1,
        y: -1,
        ground: GroundType.field,
        target: Target.none,
        isPath: false,
      );
}
