/// Represents a fixed-size two-dimensional array.
///
/// Provides methods for accessing, modifying, and iterating over elements
/// in the 2D array using x and y coordinates.  The array is initialized
/// using a `valueBuilder` function which provides the initial value for each cell.
class Array2d<T> {
  /// The underlying 2D array.
  late final List<List<T>> array;

  /// A function that builds the initial value for each cell in the array.
  /// Takes the x and y coordinates as arguments.
  final T Function(int x, int y) valueBuilder;

  /// Creates a new [Array2d] with the specified width and height.
  ///
  /// The [valueBuilder] function is used to initialize each element of the array.
  /// It is called with the x and y coordinates of each cell.
  /// Throws an [ArgumentError] if width or height are not positive.
  Array2d(int width, int height, {required this.valueBuilder}) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError("Width and height must be positive integers.");
    }
    array = List.generate(
        width, (x) => List.generate(height, (y) => valueBuilder(x, y)),
        growable: false);
  }

  /// Accesses the row at the given x-coordinate.
  List<T> operator [](int x) => array[x];

  /// The width of the 2D array.
  int get width => array.length;

  /// The height of the 2D array.
  int get height => array.isNotEmpty ? array[0].length : 0;

  /// Returns the first row of the 2D array.
  get first => array.first;


  /// Returns the number of rows (width) of the array.  (Same as [width])
  get length => array.length;


  /// Resizes the array to the new width and height.
  ///
  /// Existing values are copied to the new array. New cells are
  /// initialized using the `valueBuilder`. Throws an [ArgumentError]
  /// if [newWidth] or [newHeight] are not positive.
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

  /// Sets the value at the specified x and y coordinates.
  ///
  /// Throws a [RangeError] if the coordinates are out of bounds.
  void setValue(int x, int y, T value) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      array[x][y] = value;
    } else {
      throw RangeError(
          "Index out of bounds: x=$x, y=$y, width=$width, height=$height");
    }
  }

  /// Gets the value at the specified x and y coordinates.
  ///
  /// Throws a [RangeError] if the coordinates are out of bounds.
  T getValue(int x, int y) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      return array[x][y];
    } else {
      throw RangeError(
          "Index out of bounds: x=$x, y=$y, width=$width, height=$height");
    }
  }

  /// Iterates over each element in the 2D array and calls the provided function.
  void forEach(void Function(T value, int x, int y) action) {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        action(array[x][y], x, y);
      }
    }
  }

  /// Iterates over each row in the 2D array and calls the provided function.
  void forEachRow(void Function(List<T> row, int x) action) {
    for (int x = 0; x < width; x++) {
      action(array[x], x);
    }
  }

  /// Iterates over each column in the 2D array and calls the provided function.
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
