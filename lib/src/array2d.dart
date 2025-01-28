// /**
//  * canvas-astar.dart
//  * MIT licensed
//  *
//  * Created by Daniel Imms, http://www.growingwiththeweb.com
//  */

// class Array2d<T> {
//   late final List<List<T>> array;
//   T defaultValue;

//   Array2d(int width, int height, {required this.defaultValue}) {
//     array = <List<T>>[];
//     _width(width);
//     _height(height);
//   }

//   List<T> operator [](int x) => array[x];

//   get first => array.first;
//   get length => array.length;

//   void _width(int v) {
//     while (array.length > v) {
//       array.removeLast();
//     }
//     while (array.length < v) {
//       final List<T> row = [];
//       if (array.isNotEmpty) {
//         for (int y = 0; y < array.first.length; y++) {
//           row.add(defaultValue);
//         }
//       }
//       array.add(row);
//     }
//   }

//   void _height(int v) {
//     while (array.first.length > v) {
//       for (int x = 0; x < array.length; x++) {
//         array[x].removeLast();
//       }
//     }
//     while (array.first.length < v) {
//       for (int x = 0; x < array.length; x++) {
//         array[x].add(defaultValue);
//       }
//     }
//   }
// }

class Array2d<T> {
  late final List<List<T>> array;
  final T defaultValue;

  Array2d(int width, int height, {required this.defaultValue}) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError("Width and height must be positive integers.");
    }
    array = List.generate(width, (_) => List.filled(height, defaultValue),
        growable: false);
  }

  List<T> operator [](int x) => array[x];

  int get width => array.length;
  int get height => array.isNotEmpty ? array[0].length : 0; // Handle empty case
  get first => array.first;
  get length => array.length;

  // More efficient resizing
  void resize(int newWidth, int newHeight) {
    if (newWidth <= 0 || newHeight <= 0) {
      throw ArgumentError("New width and height must be positive integers.");
    }

    final newArray = List.generate(
        newWidth, (_) => List<T>.filled(newHeight, defaultValue),
        growable: false);

    // Copy existing data (as much as possible)
    for (int x = 0; x < width && x < newWidth; x++) {
      for (int y = 0; y < height && y < newHeight; y++) {
        newArray[x][y] = array[x][y];
      }
    }

    array = newArray;
  }

  // Example usage: Setting a value
  void setValue(int x, int y, T value) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      array[x][y] = value;
    } else {
      throw RangeError(
          "Index out of bounds: x=$x, y=$y, width=$width, height=$height");
    }
  }

  // Example usage: Getting a value
  T getValue(int x, int y) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      return array[x][y];
    } else {
      throw RangeError(
          "Index out of bounds: x=$x, y=$y, width=$width, height=$height");
    }
  }

  void forEach(void Function(T value, int x, int y) action) {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        action(array[x][y], x, y);
      }
    }
  }

  void forEachRow(void Function(List<T> row, int x) action) {
    for (int x = 0; x < width; x++) {
      action(array[x], x);
    }
  }

  void forEachColumn(void Function(List<T> column, int y) action) {
    for (int y = 0; y < height; y++) {
      List<T> column = [];
      for (int x = 0; x < width; x++) {
        column.add(array[x][y]);
      }
      action(column, y);
    }
  }
}
