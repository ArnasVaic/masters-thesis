#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "../../../config/diagram.typ": diagram_style
#show: diagram_style

#figure(
  diagram(
    node-stroke: 1pt,
    node-fill: rgb("#eeddff"),
    node-corner-radius: 3pt,
    node((-0.75,0), name: <threshold>, [
      *`ProductThresholdBrake`*
      #align(left, [
        #raw("threshold: double") \
        #raw("initial_mass: double")
      ])
    ]),
    node((0.75,0), name: <fixed-step>, [
      *`FixedStepBrake`*
      #align(left, [
        #raw("steps: size_t")
      ])
    ]),
    node((0,0), name: <fixed-time>, [
      *`FixedTimeBrake`*
      #align(left, [
        #raw("t_end: double")
      ])
    ]),
    node((0,1), name: <interface>, [
      *`IBrake`*
      #align(left, [
        #raw("shouldBrake(s: SolverState): bool")
      ])
    ]),
    
    edge(<fixed-step>, <interface>, "-|>"),
    edge(<threshold>, <interface>, "-|>"),
    edge(<fixed-time>, <interface>, "-|>"),
  ),
  caption: [ Reakcijos stabdymo strategijos sąsaja (_angl. interface_) ir naudojamos realizacijos ]
) <brake-component-diagram>