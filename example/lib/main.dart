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
  late ValueNotifier<bool> update;
  IconData lastTapped = Icons.notifications;
  late final Array2d<Floor> array2d;
  @override
  void initState() {
    super.initState();
    update = ValueNotifier(false);
    array2d = Array2d<Floor>(10, 10, defaultValue: Floor.none);
    for (var x = 0; x < 10; x++) {
      for (var y = 0; y < 10; y++) {
        if ((x >= 1 && x < 4 && y == 1) || (x == 1 && y == 2) ||(x >=1 && x < 4 && y ==3)) {
          array2d[x][y] = Floor(
            x: x,
            y: y,
            ground: GroundType.water,
            target: Target.none,
          );
        } else if (x >= 4 && x < 8 && y >= 5 && y < 9) {
          array2d[x][y] = Floor(
            x: x,
            y: y,
            ground: GroundType.forest,
            target: Target.none,
          );
        } else if (x >= 2 && x < 4 && y >= 4 && y < 6) {
          array2d[x][y] = Floor(
            x: x,
            y: y,
            ground: GroundType.barrier,
            target: Target.none,
          );
        } else if (x == 0 && y == 0) {
          array2d[x][y] = Floor(
            x: x,
            y: y,
            ground: GroundType.field,
            target: Target.player,
          );
        } else {
          array2d[x][y] = Floor(
            x: x,
            y: y,
            ground: GroundType.field,
            target: Target.none,
          );
        }
      }
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
    debugPrint("PATH ${path.length} ${update.value}");
    array2d.forEach((floor, x, y) => floor.isPath = false);
    for (var p in path) {
      array2d[p.x][p.y].isPath = true;
    }
    setState(() {
      update.value = !(update.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 10 * 200),
          child: Flow(
            delegate: MyFlowDelegate(updater: update),
            children: [
              for (var x = 0; x < 10; x++)
                for (var y = 0; y < 10; y++) flowMenuItem(array2d[x][y])
            ],
          ),
        ),
      ),
    );
  }

  Widget flowMenuItem(Floor floor) {
    return GestureDetector(
      onTap: () async {
        await _updateMenu(floor);
      },
      child: Center(
        child: ListenableBuilder(
          listenable: update,
          builder: (context, _) {
            return Container(
              margin: EdgeInsets.all(8),
              constraints: BoxConstraints(
                maxHeight: 96,
                maxWidth: 96,
                minWidth: 96,
                minHeight: 96,
              ),
              color: switch (floor.ground) {
                _ when floor.isPath => Colors.grey,
                GroundType.field => Colors.green[200],
                GroundType.water => Colors.cyanAccent,
                GroundType.forest => Colors.green[700],
                GroundType.barrier => Colors.red[700],
              }!,
              child: Column(
                children: [
                  Icon(
                    switch (floor.ground) {
                      GroundType.field => Icons.grass,
                      GroundType.water => Icons.water,
                      GroundType.forest => Icons.forest,
                      GroundType.barrier => Icons.block,
                    },
                    color: Colors.white,
                    size: 20.0,
                  ),
                  Text(
                    switch (floor.target) {
                      Target.player => 'PLAYER',
                      Target.enemy => 'ENEMY',
                      Target.none => '',
                    },
                  ),
                  Text(
                    switch (floor.ground) {
                      GroundType.field => '1',
                      GroundType.water => '7',
                      GroundType.forest => '10',
                      GroundType.barrier => 'x',
                    },
                  )
                ],
              ),
            );
          },
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
    final startPoint = (context.size / 3);
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

class Floor {
  Floor({
    required this.x,
    required this.y,
    required this.target,
    required this.ground,
    this.isPath = false,
  });
  late int x;
  late int y;
  late GroundType ground;
  late Target target;
  late bool isPath;

  static final none = Floor(
    x: -1,
    y: -1,
    ground: GroundType.field,
    target: Target.none,
    isPath: false,
  );
}
