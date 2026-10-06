#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "../../../config/diagram.typ": diagram_style
#show: diagram_style

#figure(
  diagram(
    node-stroke: 1pt,
    node-fill: rgb("#e9e9e9"),
    node-corner-radius: 3pt,
    node((-1,0), name: <fixed>, [
      *`FixedTimeStep`*
      #align(left)[
        `+ dt: double`
      ]
    ]),
  ),
  caption: [ UML būsenos diagrama, sprendiklio algoritmo būsena ]
) <solver-loop-diagram>