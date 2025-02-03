import 'dart:math';

class WeightedPoint extends Point<int> {
  const WeightedPoint(super.x, super.y, {required this.weight});
  final int weight;
}

class DistancePoint extends Point<int> {
  DistancePoint(super.x, super.y, this.distance);
  final double distance;
}
