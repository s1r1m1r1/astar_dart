// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:ui';

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

class _GridExampleState extends State<GridExample>
    with SingleTickerProviderStateMixin {
  late ValueNotifier<bool> updater;
  IconData lastTapped = Icons.notifications;
  late final Array2d<Floor> array2d;
  var _player = (x: 0, y: 0);
  final int _rows = 10;
  final int _cols = 10;
  var _path = <Point>[];
  int _pathIndex = 0;
  Point _playerTo = (x: 0, y: 0);
  Point _playerFrom = (x: 0, y: 0);
  final _visited = ValueNotifier(<Point>[]);
  late final AnimationController _animController;

  void _onAnimationCompleted(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.dismissed:
        print('Animation Dismissed');
        break;
      case AnimationStatus.forward:
        print('Animation Forward');
        break;
      case AnimationStatus.reverse:
        print('Animation Reverse');
        break;
      case AnimationStatus.completed:
        print('Animation Completed');
        _nextAnim();
        break;
    }
  }

  void _nextAnim() {
    _player = _playerFrom;
    _playerFrom = _playerTo;
    final maxIndex = _path.length - 1;
    if (_pathIndex < maxIndex) {
      _pathIndex++;
      _playerTo = _path[_pathIndex];
      _animController.reset();
      _animController.forward();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    updater.dispose();
    _visited.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _animController.addStatusListener(_onAnimationCompleted);
    _visited.addListener(() {
      _visited.value.map((i) {
        array2d.elementAt(i.x, i.y).isVisited = true;
      });
      updater.value = !updater.value;
    });

    updater = ValueNotifier(false);
    array2d = Array2d<Floor>(_rows, _cols, valueBuilder: (x, y) {
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

  Future<void> _updateFloor(Floor floor, {required Point startPos}) async {
    final astar = AStarManhattan(
      rows: _rows,
      columns: _cols,
      gridBuilder: (x, y) {
        final floor = array2d.elementAt(x, y);
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

    final path = await Future.value(astar.findPath(
      start: startPos,
      end: (x: floor.x, y: floor.y),
      visited: (visited) {
        print("VISITED ${visited.length}");
        visited.map((i) {
          array2d.elementAt(i.x, i.y).isVisited = true;
        });
      },
    ));
    for (var floor in array2d.array) {
      floor.isPath = false;
      floor.isVisited = false;
    }

    for (var p in path) {
      array2d.elementAt(p.x, p.y).isPath = true;
    }
    _path = path.reversed.map((i) => (x: i.x, y: i.y)).toList();
    _pathIndex = 0;
    _nextAnim();
    updater.value = !updater.value;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final gridSize = Size(_cols * 100, _rows * 100);
    return DefaultTextStyle(
      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenSize = constraints.biggest;
          final boundaryMargin = screenSize.width > gridSize.width
              ? EdgeInsets.zero
              : EdgeInsets.fromLTRB(
                  20,
                  20,
                  (gridSize.width - screenSize.width + 20),
                  (screenSize.height > gridSize.height)
                      ? 20
                      : (gridSize.height - screenSize.height + 40));
          return Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: gridSize.width,
                height: gridSize.height,
                child: InteractiveViewer(
                  panAxis: PanAxis.free,
                  boundaryMargin: boundaryMargin,
                  minScale: 0.1,
                  maxScale: 1.6,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Flow(
                            delegate: MyFlowDelegate(
                                updater: updater, rows: _rows, cols: _cols),
                            children: [
                              for (var x = 0; x < _rows; x++)
                                for (var y = 0; y < _cols; y++)
                                  FloorItemWidget(
                                    floor: array2d.elementAt(x, y),
                                    onTap: (floor) async {
                                      await _updateFloor(floor,
                                          startPos: _player);
                                    },
                                  ),
                            ]),
                      ),
                      AnimatedBuilder(
                          animation: _animController,
                          builder: (context, _) {
                            final anim = _animController.value;
                            final from = Offset(
                                _playerFrom.x * 100, _playerFrom.y * 100);
                            final to =
                                Offset(_playerTo.x * 100, _playerTo.y * 100);
                            final offset = Offset.lerp(from, to, anim)!;

                            final scale = anim == 0.0 || anim == 1.0
                                ? 1.0
                                : anim <= 0.5
                                    ? lerpDouble(1.0, 1.5, anim + 0.5)!
                                    : lerpDouble(1.5, 1.0, anim)!;
                            return Positioned(
                              top: offset.dy,
                              left: offset.dx,
                              width: 100,
                              height: 100,
                              child: Transform.scale(
                                scale: scale,
                                child: Center(
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Container(
                                          height: 75,
                                          width: 75,
                                          decoration: BoxDecoration(
                                              color: Colors.orangeAccent,
                                              boxShadow: [
                                                BoxShadow(
                                                    color:
                                                        Colors.blueGrey[800]!,
                                                    offset: Offset(5, 5),
                                                    blurRadius: 5.0,
                                                    spreadRadius: 5)
                                              ],
                                              shape: BoxShape.circle),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  children: [
                                                    Spacer(),
                                                    Container(
                                                      height: 20,
                                                      width: 20,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    SizedBox(width: 16),
                                                    Container(
                                                      height: 20,
                                                      width: 20,
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    Spacer(),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Center(
                                                  child: Container(
                                                    width: 20,
                                                    height: 5,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          })
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
          child: ClipRect(
            child: GestureDetector(
              onTap: () {
                onTap(floor);
              },
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox.square(
                  dimension: 100,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                        color: floor.isPath
                            ? Colors.purple
                            : floor.isVisited
                                ? Colors.grey
                                : switch (floor.ground) {
                                    GroundType.field => Colors.green[200],
                                    GroundType.water => Colors.cyanAccent,
                                    GroundType.forest => Colors.green[700],
                                    GroundType.barrier => Colors.red[700],
                                  },
                        border: Border.all(color: Colors.black, width: 3.0)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
    required this.x,
    required this.y,
    required this.target,
    required this.ground,
    this.isPath = false,
    this.isVisited = false,
  });

  final int x, y;
  bool isPath;
  bool isVisited;

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

class MyFlowDelegate extends FlowDelegate {
  final int rows;
  final int cols;
  MyFlowDelegate(
      {required this.updater, required this.rows, required this.cols})
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
      final y = i % cols;
      final x = i ~/ rows;

      context.paintChild(
        i,
        transform: Matrix4.translationValues(-startPoint.width + (x * 100.0),
            -startPoint.height + (y * 100.0), 0),
      );
    }
  }
}
