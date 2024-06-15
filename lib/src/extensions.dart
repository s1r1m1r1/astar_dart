import 'dart:math';

import '../astar_dart.dart';

extension BarrierExt on Barrier {
  bool get isBlock => this == Barrier.block;
  bool get isPass => this == Barrier.pass;
  bool get isPathThrough => this == Barrier.passThrough;
}

extension ListNodeExt on List<ANode> {
  List<Point<int>> toPointList() => map((n) => Point(n.x, n.y)).toList();
}

extension ANodeExt on ANode {
  Point<int> toPoint() => Point<int>(x, y);
}

extension PointExt on Point<int> {
  BarrierPoint toBarrier(Barrier barrier) =>
      BarrierPoint(x, y, barrier: barrier);
}

extension ListPointExt on List<Point<int>> {
  List<BarrierPoint> toListBarrier(Barrier barrier) =>
      map((p) => BarrierPoint(p.x, p.y, barrier: barrier)).toList();
}
