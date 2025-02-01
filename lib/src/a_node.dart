// ignore_for_file: public_member_api_docs, sort_constructors_first
// abstract class Node {}

import '../astar_dart.dart';

class ANode implements Comparable<ANode> {
  final int x;
  final int y;
  ANode? parent;
  final List<ANode> neighbors;
  Barrier barrier;
  double weight;

  /// distanse from current to start
  double g = 0;

  /// distanse from current to end
  double h = 0;

  /// total distance
  double get f => g + h;

  ANode(
      {required this.x,
      required this.y,
      required this.neighbors,
      this.barrier = Barrier.pass,
      this.parent,
      this.weight = 1});

  @override
  bool operator ==(covariant ANode other) {
    return other.x == x && other.y == y;
  }

  @override
  int get hashCode {
    return Object.hashAll([x, y]);
  }

  @override
  int compareTo(ANode other) {
    int result = f.compareTo(other.f); // Compare f values first
    if (result == 0) {
      // Tie-breaker using h if f values are equal
      result = h.compareTo(other.h);
    }
    return result;
  }
}
