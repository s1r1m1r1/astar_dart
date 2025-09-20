import 'dart:math';

class WeightedPoint extends Point<int> {
  const WeightedPoint(super.x, super.y, {required this.weight});
  final int weight;
}

class DistancePoint extends Point<int> {
  DistancePoint(super.x, super.y, this.distance);
  final int distance;
}

/// --------------------------------------------
class MovePoint extends DistancePoint {
  MovePoint(super.x, super.y, super.distance);
}

class PassByPoint extends DistancePoint {
  PassByPoint(super.x, super.y, super.distance);
}

class TargetPoint extends DistancePoint {
  TargetPoint(super.x, super.y, super.distance);
}
///----------------------------------------------