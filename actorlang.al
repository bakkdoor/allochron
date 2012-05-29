# Split = Actor behavior name
# (left, right) - List variables that make up the state of the actor, can be changed via `become`
# msg: { ... } - A function literal / actor handler that gets called with every incoming message until it is changed via `become`
Split (left, right) = msg: {
  left <- msg   # send msg to left
  right <- msg
}

Join (left, right, output) = msg: {
  # sender always refers to sender of msg
  # self always refers to current actor this handler is run for
  match sender {
    case left { output <- msg }
    case right { output <- msg }
    # match all
    case _ { println <- ("Invalid sender: ", sender) }
  }
}

Count (max, block) = msg: {
  match msg {
    # partial blocks as in fancy
    case @{ <= 0 } { die! }
    case _ {
      block <- msg
      become (max - 1, block) # only change state for next message, not handler
    }
  }
}

Repeat (block) = msg: {
  block <- msg
}

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

Map (target, block) = enum: {
  match enum {
    case (x, y) {
      (block <- x) -> f # save reply of (block <- x) in f (a future)
      self <- y
      target <- @f # explicitly dereference f (a future) - blocks if not fully computed yet
    }
  }
}

Dispatcher (target, actor) = enum: {
  match enum {
    case (x, y) {
      # register callback for future returned by (actor <- x) message send
      with (actor <- x) val: {
        target <- val
      }
      self <- y
    }
  }
}

Square () = (num): {
  become Future((num, num * num))
  reply self
}

# main actor
Main () = argv: {
  # same as:
  # spawn DoEach(arg: { println <- arg })
  @DoEach(arg: { println <- arg }) <- argv
  @Map(self, @Square) <- argv
}

# alternative
Main = argv: {
  doeach = spawn DoEach(arg: { println <- arg })
  doeach <- argv
  map = spawn Map(arg: { println <- arg })
  map <- argv
}

### future implementation

Broadcast {
  Value (val) = list: {
    @DoEach(@{ <- val }) <- list
    # this is the same as:
    @DoEach(receiver: { receiver <- val }) <- list
  }

  Change (future) = list: {
    @DoEach(@{ <- @future }) <- list
  }
}

Future {
  # Future is implicit in here.
  # any identifier followed by a block of code in { and }
  # is implicit in the block
  # e.g. this is the same as: Future:Waiting (waiting) = msg: { ...
  Waiting (waiting) = msg: {
    match msg {
      case ('write, val) {
        become Value(val)
        reply self
        @Broadcast:Value(val) <- waiting
      }
    }
  }

  # inline pattern matching in the argument list of a function works too:
  Value (val) = ('read): { reply val }

  # which is the same as this:
  Value (val) = msg: {
    match msg {
      case ('read) { reply val}
      # and this could be written as follows too:
      case 'read { reply val }
    }
  }

  # same as:
  # Future () = msg: { ...
  () = msg: {
    match msg {
      case ('write, val) {
        become Future:Value(val)
      }
      case 'read {
        become Future:Waiting([sender])
      }
    }
  }
}



# anonymous actors

spawn (name) msg: {
  println <- ("Hello, my name is ", name, " and you said: ", msg)
}("Christopher")

square = spawn x: { reply x * x}
with (square <- 2) x: { println <- x } # print 4


# literals:

# numbers:
1123
123.123
0b1010100 # (same as in fancy)

# strings:
"fooo"
"foo#{2 * 2}"

# symbols:
'foo
'foo:bar:

# functions
{ println <- "hello, world!" }
x: { println <- x }
(x,y): { println <- (x + y) }