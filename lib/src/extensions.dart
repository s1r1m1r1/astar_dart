import 'dart:math';
import 'package:astar_dart/astar_dart.dart';

extension ListNodeExt on List<ANode> {
  List<Point<int>> toPointList() => map((n) => Point(n.x, n.y)).toList();
}
