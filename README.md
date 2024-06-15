
# astar_dart


# TODO
  - Random movement
     Variable pathfinding. Receive different ways for the same input
  - Hex astar
  - Search for neighbors at the finishing point. Useful for tbs games
  - Search for nearby goals and move towards it.
     Useful for AI behavior such as npc

# Usage
To use this plugin, add `astar_dart` as a [dependency in your pubspec.yaml file](https://flutter.io/platform-plugins/).

### Example

``` dart
import 'dart:math';

import 'package:astar_dart/astar_dart.dart';
import 'package:flutter/material.dart';
import 'package:timing/timing.dart';

void main() {
  runApp(MaterialApp(
    title: 'Astar demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const ExamplePage(),
  ));
}

enum TypeInput {
  start,
  barrier,
  target,
  water,
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => ExamplePageState();
}

class ExamplePageState extends State<ExamplePage> {
  TypeInput _typeInput = TypeInput.start;

  // benchmark timing
  TimeTracker? timeTracker;

  bool _showDoneList = true;
  bool _withDiagonals = true;
  Point<int> start = Point<int>(0, 0);
  List<Tile> tiles = [];
  List<Point<int>> barriers = [
    ...List.generate(6, (i) => Point(2, 4 + i)),
    Point(3, 4),
    ...List.generate(5, (i) => Point(4, 4 + i)),
    Point(2, 10),
    Point(3, 10),
    Point(4, 10),
    ...List.generate(5, (i) => Point(4 + i, 0 + i)),
  ];
  List<WeightedPoint> weighted = [
    ...List.generate(4, (i) => WeightedPoint(5 + i, 5, weight: 5)),
    ...List.generate(8, (i) => WeightedPoint(8, 5 + i, weight: 5)),
    ...List.generate(10, (i) => WeightedPoint(8 + i, 13, weight: 5)),
  ];
  List<Point<int>> targets = [];
  late int _rows;
  late int _columns;
  late AStarSquareGrid _astar;

  @override
  void initState() {
    super.initState();
    _rows = 20;
    _columns = 20;
    _astar = AStarSquareGrid(rows: _rows, columns: _columns);
    for (int x = 0; x < _rows; x++) {
      for (int y = 0; y < _columns; y++) {
        final point = Point(x, y);
        tiles.add(Tile(point));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('A* double tap to find path'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: Row(
              children: [
                if (_showDoneList)
                  Text(
                    'done list ${tiles.where((i) => i.done).length},\npath length ${tiles.where((i) => i.selected).length} ${_getBenchmark()}',
                  )
              ],
            ),
          ),
          Row(
            children: [
              Text('with diagonals'),
              Switch(
                value: _withDiagonals,
                onChanged: (value) {
                  setState(() {
                    _withDiagonals = value;
                  });
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _typeInput = TypeInput.start;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: _getColorSelected(TypeInput.start),
                  ),
                  child: Text('START'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _typeInput = TypeInput.water;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: _getColorSelected(TypeInput.water),
                  ),
                  child: Text('WATER'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _typeInput = TypeInput.barrier;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: _getColorSelected(TypeInput.barrier),
                  ),
                  child: Text('BARRIES'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _typeInput = TypeInput.target;
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: _getColorSelected(TypeInput.target),
                  ),
                  child: Text('TARGETS'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: _columns,
              children: tiles.map((e) {
                return _buildItem(e);
              }).toList(),
            ),
          ),
          Row(
            children: [
              Switch(
                value: _showDoneList,
                onChanged: (value) {
                  setState(() {
                    _showDoneList = value;
                  });
                },
              ),
              Text('Show done list')
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(Tile e) {
    Color color = Colors.white;
    String text = '1';
    if (weighted.contains(e.position)) {
      color = Colors.cyan;
      text = weighted
          .firstWhere((i) => i.x == e.position.x && i.y == e.position.y)
          .weight
          .toString();
    }
    if (barriers.contains(e.position)) {
      color = Colors.red.withOpacity(.7);
      text = 'barrier';
    }
    if (e.done) {
      color = Colors.black.withOpacity(.2);
    }
    if (e.selected && _showDoneList) {
      color = Colors.green.withOpacity(.7);
    }

    if (targets.contains(e.position)) {
      color = Colors.purple.withOpacity(.7);
      text = text + '\ntarget';
    }

    if (e.position == start) {
      color = Colors.yellow.withOpacity(.7);
      text = text + '\nstart';
    }

    return Ink(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54, width: 1.0),
        color: color,
      ),
      height: 10,
      child: InkWell(
        child: Text(
          text,
          style: TextStyle(fontSize: 9, color: Colors.black),
        ),
        onDoubleTap: () => _start(e.position),
        onTap: () {
          if (_typeInput == TypeInput.start) {
            start = e.position;
          }

          if (_typeInput == TypeInput.barrier) {
            if (barriers.contains(e.position)) {
              barriers.remove(e.position);
            } else {
              barriers.add(e.position);
            }
          }
          if (_typeInput == TypeInput.target) {
            if (targets.contains(e.position)) {
              targets.remove(e.position);
            } else {
              targets.add(e.position);
            }
          }
          if (_typeInput == TypeInput.water) {
            if (weighted.contains(e.position)) {
              weighted.remove(e.position);
            } else {
              weighted
                  .add(WeightedPoint(e.position.x, e.position.y, weight: 5));
            }
          }
          setState(() {});
        },
      ),
    );
  }

  String _getBenchmark() {
    if (timeTracker == null) return '';
    if (!timeTracker!.isFinished) return '';
    final duration = timeTracker!.duration;
    return 'benchmark: inMilliseconds: ${duration.inMilliseconds}';
  }

  MaterialStateProperty<Color> _getColorSelected(TypeInput input) {
    return MaterialStateProperty.all(
      _typeInput == input ? _getColorByType(input) : Colors.grey,
    );
  }

  Color _getColorByType(TypeInput input) {
    switch (input) {
      case TypeInput.start:
        return Colors.yellow;
      case TypeInput.barrier:
        return Colors.red;
      case TypeInput.target:
        return Colors.purple;
      case TypeInput.water:
        return Colors.blue;
    }
  }

  void _start(Point<int> target) {
    _cleanTiles();
    List<Point<int>> done = [];
    late List<Point<int>> result;
    timeTracker = SyncTimeTracker()
      ..track(() {
        _astar.setDiagonalMovement(_withDiagonals
            ? DiagonalMovement.euclidean
            : DiagonalMovement.manhattan);
        _astar.setPoints(weighted);
        _astar.setBarriers([...barriers, ...targets]
            .map((p) => BarrierPoint(p.x, p.y, barrier: Barrier.block))
            .toList());
        _astar.calculateGrid();
        result = _astar
            .findPath(
              doneList: (
                doneList,
              ) {
                done = doneList;
              },
              start: start,
              end: target,
            )
            .toPointList();
        ;
      });

    for (var element in result) {
      done.remove(element);
    }

    done.remove(start);

    setState(() {
      for (var element in tiles) {
        element.selected = result.any((r) {
          return r.x == element.position.x && r.y == element.position.y;
        });

        // if (_showDoneList) {
          element.done = done.any((r) {
            return r == element.position;
          });
        // }
      }
    });
  }

  void _cleanTiles() {
    for (var element in tiles) {
      element.selected = false;
      element.done = false;
    }
  }
}

class Tile {
  final Point<int> position;
  bool selected = false;
  bool done = false;

  Tile(this.position);
}


```
