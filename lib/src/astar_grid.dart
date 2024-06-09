import 'dart:math';

/// base class for all AstarGrid
abstract class AstarGrid {
  Iterable<Point<int>> findThePath(
      {void Function(List<Point<int>>)? doneList,
      required Point<int> start,
      required Point<int> end});
}
