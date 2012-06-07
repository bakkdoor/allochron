Enumerable {
  DoEach (func) = enum: {
    match enum {
      # we can skip this line since we'll just ignore empty lists
      # this means we still process each element in a list
      # since the (x, y) pattern only matches non-empty lists
      # any other messages get ignored (deleted).
      # but if you'd want an actor to die, simply do so:
      # case () { die! }
      case (x, y) {
        func <- x
        self <- y
      }
    }
  }

  Filter (target, func) = (x, y): {
    with (func <- x) val: {
      @If(val, { target <- x })
    }
    self <- y
  }

  Mapper (target, func, mapped=()) = list: {
    match list {
      case (x, y) {
        become (target, func, (func <- x, mapped))
      }
      case _ {
        target <- mapped
        become (target, func) # restores mapped to default (empty list)
      }
    }
  }
}
