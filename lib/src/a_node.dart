// ignore_for_file: public_member_api_docs, sort_constructors_first
// abstract class Node {}

class ANode {
  final int x;
  final int y;
  ANode? parent;
  final List<ANode> neighbors;
  late double _weight;

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
      this.parent,
      double weight = 1}) {
    _weight = weight;
  }

  void setWeight(double weight) {
    _weight = weight;
  }

  double get weight => _weight;

  @override
  bool operator ==(covariant ANode other) {
    return other.x == x && other.y == y;
  }

  @override
  int get hashCode {
    return Object.hashAll([x, y]);
  }

  static final wrong = ANode(x: -1, y: -1, neighbors: []);
}

class AHexNode {
  AHexNode({
    required this.x,
    required this.y,
    required this.neighbors,
    double weight = 1,
  })  : _weight = weight,
        u = x + y;
  final int x;
  final int y;
  final int u;
  AHexNode? parent;
  final List<AHexNode> neighbors;
  late double _weight;

  /// distanse from current to start
  double g = 0;

  /// distanse from current to end
  double h = 0;

  /// total distance
  double get f => g + h;

  void setWeight(double weight) {
    _weight = weight;
  }

  double get weight => _weight;

  @override
  bool operator ==(covariant AHexNode other) {
    return other.x == x && other.y == y;
  }

  @override
  int get hashCode {
    return Object.hashAll([x, y]);
  }

  static final wrong = AHexNode(
    x: -1,
    y: -1,
    neighbors: [],
  );

  @override
  String toString() =>
      'AHexNode(x: $x, y: $y f:$f g:$g h:$h, neighbors: ${neighbors.map((n) => "\n\t\t\t\t\t\t\t(x_${n.x} y_${n.y}  f:${n.f} g:${n.g} h:${n.h})").join(', ')})\n';
}
