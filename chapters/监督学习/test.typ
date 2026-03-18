#import "@preview/marginalia:0.3.1" as marginalia: note, notefigure, wideblock

#show: marginalia.setup.with(
  inner: ( far: 5mm, width: 5mm, sep:5mm ),
  outer: ( far: 4mm, width: 55mm, sep: 5mm ),
  top: 2.5cm,
  bottom: 2.5cm,
  book: true,
  clearance: 12pt,
)
#lorem(100)
#note[
   假设节点$E$直接影响到节点$H$，即$E→H$，则边权用条件概率$P(H|E)$来表示.
]
#lorem(100)
#figure(
  rect(width: 100%),
  caption: [A notefigure.],
)<figure-label>
#notefigure(
  rect(width: 100%),
  caption: [A notefigure.],
)<figure-label>
#pagebreak()
#lorem(100)
