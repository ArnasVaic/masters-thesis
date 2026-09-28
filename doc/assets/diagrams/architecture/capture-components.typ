#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "../../../config/diagram.typ": diagram_style
#show: diagram_style

#figure(
  diagram(
    node-stroke: 1pt,
    node-fill: rgb("#e9e9e9"),
    node-corner-radius: 3pt,
    node((-0.5,0), name: <stride-ct>, [
      *`StrideCaptureTrigger`*
      #align(left, [
        #raw("stride: size_t")
      ])
    ]),
    node((0.5,0), name: <last-frame-ct>, [
      *`LastFrameCaptureTrigger`*
      #align(left, [
        #raw("brake: IBrake")
      ])
    ]),
    node((0,1), name: <cti>, [
      *`ICaptureTrigger`*
      #align(left, [
        #raw("shouldCapture(s: SolverState): bool")
      ])
    ]),
    node((-0.5,3), name: <imfc>, [
      *`InMemoryFrameCapture`*
      #align(left, [
        #raw("capacity: size_t") \ 
        #raw("disc: Discretization")
      ])
    ]),
    node((0.5,3), name: <imqc>, [
      *`InMemoryQuantityCapture`*
      #align(left, [
        #raw("capacity: size_t") \
        #raw("disc: Discretization")
      ])
    ]),
    node((0,2), name: <ci>, [
      *`ICapture`*
      #align(left, [
        #raw("capture(s: SolverState)")
      ])
    ]),
    edge(<stride-ct>, <cti>, "-|>"),
    edge(<last-frame-ct>, <cti>, "-|>"),
    edge(<imfc>, <ci>, "-|>"),
    edge(<imqc>, <ci>, "-|>"),
  ),
  caption: [ Sprendinio laiko ir formos fiksavimo strategijos sąsajos ir naudojamos realizacijos ]
) <capture-component-diagram>