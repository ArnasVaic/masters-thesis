#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "../../../config/diagram.typ": diagram_style
#show: diagram_style

#figure(
  diagram(
    node-stroke: 1pt,
    node-fill: rgb("#eeddff"),
    node-corner-radius: 3pt,
    node((-1,0), name: <fixed>, [
      *`ThresholdBrake`*
      #align(left, [
        #raw("c5_threshold: double")
      ])
    ]),
    node((1,0), name: <exp>, [
      *`FixedStepBrake`*
      #align(left, [
        #raw("steps: size_t")
      ])
    ]),
    node((0,0.5), name: <interface>, [
      *`IBrake`*
      #align(left, [
        #raw("shouldBrake(s: SolverState): bool")
      ])
    ]),
    
    edge(<fixed>, <interface>, "-|>"),
    edge(<exp>, <interface>, "-|>"),
  ),
  caption: [ Reakcijos stabdyom strategijos sąsaja (_angl. interface_) ir galimos realizacijos ]
) <brake-component-diagram>