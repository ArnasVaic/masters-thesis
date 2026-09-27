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
      #align(left, [
        #raw("dt: double")
      ])
    ]),
    node((1,0), name: <exp>, [
      *`GeometricTimeStep`*
      #align(left, [
        #raw("dt_0: double") \
        #raw("r: double")
      ])
    ]),
    node((0,0.5), name: <capture-trigger-interface>, [
      *`ICaptureTrigger`*
      #align(left, [
        #raw("shouldCapture(s: SolverState): bool")
      ])
    ]),
    node((0,2.5), name: <capture-interface>, [
      *`ICapture`*
      #align(left, [
        #raw("capture(s: SolverState)")
      ])
    ]),
    // edge(<fixed>, <capture-interface>, "-|>"),
    // edge(<exp>, <interface>, "-|>"),
  ),
  caption: [ Sprendinio laiko ir formos fiksavimo strategijos sąsajos ir naudojamos realizacijos ]
) <capture-component-diagram>