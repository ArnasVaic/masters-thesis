#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

#import "../../../config/diagram.typ": diagram_style
#show: diagram_style

// A quantity node: the symbol with a short description underneath
#let qty(symbol, description) = box(width: 72pt)[
  #text(size: 13pt, symbol) \
  #text(size: 7pt, fill: luma(90), description)
]

#figure(
  {
    set text(size: 9pt)
    diagram(
      node-stroke: 0.8pt,
      node-fill: rgb("#e9e9e9"),
      node-corner-radius: 3pt,
      node-inset: 6pt,
      node-shape: rect,
      spacing: (6pt, 30pt),
      edge-stroke: 0.7pt,
      mark-scale: 100%,

      node((1, 0), name: <c>, qty($c(x, y, t)$, [molinė koncentracija])),
      node((0, 1), name: <q>, qty($q(t)$, [molinis kiekis])),
      node((2, 1), name: <rho>, qty($rho(x, y, t)$, [masės tankis])),
      node((1, 2), name: <m>, qty($m(t)$, [masė])),

      edge(<c>, <q>, "->", $integral_Omega c dif A$, label-side: right),
      edge(<c>, <rho>, "->", $dot M$, label-side: left),
      edge(<q>, <m>, "->", $dot M$, label-side: right),
      edge(<rho>, <m>, "->", $integral_Omega rho dif A$, label-side: left),
    )
  },
  caption: [ Galimi kadro duomenų reduktoriai. Koncentracijos laukas $c$ gali būti integruojamas sričiai $Omega$ arba dauginamas iš molinės masės $M$, o abu keliai veda į bendrą medžiagos masę $m$. ],
) <reducer-diagram>
