Enumerable {
  DoEach (block) = enum: {
    match enum {
      # we can skip this line since we'll just ignore empty lists
      # this means we still process each element in a list
      # since the (x, y) pattern only matches non-empty lists
      # any other messages get ignored (deleted).
      # but if you'd want an actor to die, simply do so:
      # case () { die! }
      case (x, y) {
        block <- x
        self <- y
      }
    }
  }
}
