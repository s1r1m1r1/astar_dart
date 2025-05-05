import 'dart:math';
import 'package:astar_dart/astar_dart.dart';

extension BarrierExt on Barrier {
  bool get isBlock => this == Barrier.block;
  bool get isPass => this == Barrier.pass;
  bool get isPathThrough => this == Barrier.passThrough;
}

extension ListNodeExt on List<ANode> {
  List<Point<int>> toPointList() => map((n) => Point(n.x, n.y)).toList();
}
