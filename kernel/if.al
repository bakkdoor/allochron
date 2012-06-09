If (condition, func) = msg: {
  match condition {
    nil | false {
      become Future(nil)
    }
    _ {
      become Future(func <- condition)
    }
  }
  reply self
}

IfElse (condition, then_func, else_func) = msg: {
  match condition {
    nil | false {
      become Future(else_func <- ())
    }
    _ {
      become Future(then_func <- condition)
    }
  }
  reply self
}