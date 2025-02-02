// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';

import '../astar_dart.dart';

typedef GridBuilder = ANode Function(int x, int y);

/// base class for all AstarGrid
abstract class AstarGrid {
  final List<ANode> doneList = [];
  final List<ANode> waitList = [];

  FutureOr<List<ANode>> findPath({
    void Function(List<Point<int>>)? doneList,
    required ({int x, int y}) start,
    required ({int x, int y}) end,
  });

  late final int rows;
  late final int columns;
  // late final Array2d<Barrier> barriers;
  // late final Array2d<int> grounds;
  late final Array2d<ANode> grid;
  // ignore: prefer_const_constructors
  var start = Point<int>(0, 0);
  // ignore: prefer_const_constructors
  var end = Point<int>(0, 0);

  final GridBuilder? gridBuilder;
  AstarGrid({
    this.gridBuilder,
    required this.rows,
    required this.columns,
    Array2d<ANode>? grid,
    // required this.barriers,
    // required this.grounds,
  }) {
    this.grid = gridBuilder != null
        ? Array2d(rows, columns, valueBuilder: gridBuilder!)
        : Array2d(rows, columns,
            valueBuilder: (x, y) => ANode(x: x, y: y, neighbors: []));
  }
// abstract
  addNeighbors();

  // calculateGrid();
}
