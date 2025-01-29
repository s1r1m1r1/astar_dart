// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';

import '../astar_dart.dart';

/// base class for all AstarGrid
abstract class AstarGrid {
  // Future<List<ANode>> findPath(
  //     {void Function(List<Point<int>>)? doneList,
  //     required Point<int> start,
  //     required Point<int> end});

  // void addNeighbors();

  FutureOr<List<ANode>> findPath({
    void Function(List<Point<int>>)? doneList,
    required Point<int> start,
    required Point<int> end,
  });

  late final int rows;
  late final int columns;
  late final Array2d<Barrier> barriers;
  late final Array2d<int> grounds;
  late final Array2d<ANode> grid;
  // ignore: prefer_const_constructors
  var start = Point<int>(0, 0);
  // ignore: prefer_const_constructors
  var end = Point<int>(0, 0);

  AstarGrid({
    required this.rows,
    required this.columns,
    required this.barriers,
    required this.grounds,
  }) {
    grid = Array2d(rows, columns, valueBuilder: (x,y)=> ANode.wrong);
  }
// abstract
  addNeighbors();
}
