import 'package:astar_dart/astar_dart.dart';

extension ListNodeExt on List<ANode> {
  List<Point> toPointList() => map((n) => (x: n.x, y: n.y)).toList();
}
