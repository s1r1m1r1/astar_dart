import 'package:astar_dart/astar_dart.dart';
import 'package:test/test.dart';

void main() {
  late final AStarHex astar;
  setUpAll(() {
    astar = AStarHex(
      rows: 7,
      columns: 7,
      gridBuilder: (x, y) {
        if ((x == 1 && y == 1) || (x == 1 && y == 0)) {
          return ANode(x: x, y: y, neighbors: [], isBarrier: true);
        }
        return ANode(x: x, y: y, neighbors: []);
      },
    );
    astar.addNeighbors();
  });

  group('test AStarHex find targets', () {
    test(
      'test 1',
      () {
        final path = astar.findTargets(
          steps: 14,
          start: (x: 0, y: 0),
          targets: const [
            (x: 6, y: 6),
            (x: 5, y: 5),
            (x: 2, y: 0),
          ],
        );
        expect(path[0].distance, 5.0); // Check number of cols
        expect(path[1].distance, 10.0); // Check number of cols
        expect(path[2].distance, 12.0); // Check number of cols
      },
    );
  });
}
