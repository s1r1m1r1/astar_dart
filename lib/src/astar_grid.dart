import 'dart:math';

import 'package:astar_dart/src/a_node.dart';

/// base class for all AstarGrid
abstract class AstarGrid {
  List<ANode> findPath(
      {void Function(List<Point<int>>)? doneList,
      required Point<int> start,
      required Point<int> end});
}
