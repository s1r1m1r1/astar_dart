class Array2d<T> {
  late final List<List<T>> array;
  final T Function(int x, int y) valueBuilder;

  Array2d(int width, int height, {required this.valueBuilder}) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError("Width and height must be positive integers.");
    }
    array = List.generate(
        width, (x) => List.generate(height, (y) => valueBuilder(x, y)),
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
        newWidth, (x) => List<T>.generate(newHeight, (y) => valueBuilder(x, y)),
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
