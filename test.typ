#set page(paper: "a4")

$ x_(k+1)^i = cases(
  z^i - lambda/L &"if" lambda/L < z^i,
  0 &"if" |z^i| <= lambda/L,
  z^i + lambda/L &"if" z^i < -lambda/L
) $