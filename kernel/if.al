If (condition, func) = msg: {
  match condition {
    case nil | false {
      become Future(nil)
    }
    case _ {
      become Future(func <- condition)
    }
  }
  reply self
}

IfElse (condition, then_func, else_func) = msg: {
  match condition {
    case nil | false {
      become Future(else_func <- ())
    }
    case _ {
      become Future(then_func <- condition)
    }
  }
  reply self
}