enum DiagonalMovement {
  /// Only allow vertical and horizontal movement
  manhattan,

  /// Allow vertical, horizontal, and diagonal movement
  euclidean,

  /// Allow vertical, horizontal, and diagonal movement
  /// with same cost chain
  chebychev,
}
