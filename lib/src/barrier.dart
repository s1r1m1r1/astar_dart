enum Barrier {
  // Can move through the barrier
  pass,

  // Cannot move through the barrier
  block,

  // Can move through but cannot stop on it
  passThrough,
}
