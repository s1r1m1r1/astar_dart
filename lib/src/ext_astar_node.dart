import 'dart:math';

import 'package:astar_dart/src/astar_node.dart';

extension AstarNodeExt on List<AstarNode>{
  List<Point<int>> toPointList()=> map((n) => Point(n.x, n.y)).toList();

}