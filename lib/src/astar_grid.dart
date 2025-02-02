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
  late final Array2d<ANode> grid;

  final GridBuilder? gridBuilder;
  AstarGrid({
    this.gridBuilder,
    required this.rows,
    required this.columns,
  }) {
    grid = Array2d(
      rows,
      columns,
      valueBuilder: gridBuilder ??
          (x, y) => ANode(
                x: x,
                y: y,
                neighbors: [],
              ),
    );
  }
// abstract
  addNeighbors();
}
