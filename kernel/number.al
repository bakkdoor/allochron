Number {
  Square () = num: {
    reply become Future((num, num * num))
  }

  Double () = num: {
    reply become Future((num, num * 2))
  }

  Cube () = num: {
    reply become Future((num, num * num * num))
  }
}
