import 'dart:math';

import '../astar_dart.dart';

class WeightedPoint extends Point<int> {
  const WeightedPoint(super.x, super.y, {required this.weight});
  final int weight;
}

class BarrierPoint extends Point<int> {
  const BarrierPoint(super.x, super.y, {required this.barrier});
  final Barrier barrier;
}
