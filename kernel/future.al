Future {
  # Future is implicit in here.
  # any identifier followed by a block of code in { and }
  # is implicit in the block
  # e.g. this is the same as: Future:Waiting (waiting) = msg: { ...
  Waiting (waiting) = msg: {
    match msg {
      ('write, val) {
        become Value(val)
        reply self
        @Broadcast:Value(val) <- waiting
      }
      'read {
        become Waiting((sender, waiting))
      }
    }
  }

  # inline pattern matching in the argument list of a function works too:
  Value (val) = ('read): { reply val }

  # which is the same as this:
  Value (val) = msg: {
    match msg {
      ('read) { reply val}
      # and this could be written as follows too:
      'read { reply val }
    }
  }

  # same as:
  # Future () = msg: { ...
  () = msg: {
    match msg {
      ('write, val) {
        become Future:Value(val)
      }
      'read {
        become Future:Waiting([sender])
      }
    }
  }
}
