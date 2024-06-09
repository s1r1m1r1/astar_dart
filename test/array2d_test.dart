import 'package:astar_dart/src/array2d.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test initializaition', () {
    final array = Array2d<bool>(3, 4, defaultValue: true);
    expect(array.length, 3); // Check number of cols
    expect(array[0].length, 4); // Check number of rows in first row
    expect(array[0][0], true); // Check default value for elements
  });

  test('test String defaultValue', () {
    final array = Array2d<String>(2, 2, defaultValue: "empty");
    expect(array[0][1], "empty"); // Check custom default value
  });

  test('test String defaultValue', () {
    final array = Array2d<String>(2, 2, defaultValue: "empty");
    expect(array[0][1], "empty"); // Check custom default value
  });

  test('test shrink', () {
    final array = Array2d<bool>(5, 3, defaultValue: true);
    array.width = 2;
    expect(array.length, 2); // Rows remain the same
    expect(array[0].length, 3); // Columns are reduced
  });

  test('test expand', () {
    final array = Array2d<bool>(4, 5, defaultValue: true);
    array.height = 6;
    expect(array.length, 4); // Rows remain the same
    expect(array[0].length, 6); // Columns
    expect(array[0].last, true);
  });

  test('test modification', () {
    final array = Array2d<bool>(3, 2, defaultValue: true);
    array[1][0] = false;
    expect(array[1][0], false);
  });
}
