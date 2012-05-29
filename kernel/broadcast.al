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
