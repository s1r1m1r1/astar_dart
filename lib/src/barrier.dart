enum Barrier {
  // Can move through the barrier
  pass,

  // Cannot move through the barrier
  block,

  // Cannot move through the barrier, but can be founded

  // Can move through but cannot stop on it
  passThrough,
}
