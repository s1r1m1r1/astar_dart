import 'dart:math';

import '../astar_dart.dart';

extension BarrierExt on Barrier {
  bool get isBlock => this == Barrier.block;
  bool get isPass => this == Barrier.pass;
  bool get isPathThrough => this == Barrier.passThrough;
}

extension AstarNodeExt on List<AstarNode> {
  List<Point<int>> toPointList() => map((n) => Point(n.x, n.y)).toList();
}
