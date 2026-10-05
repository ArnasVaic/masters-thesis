#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "../../../config/diagram.typ": diagram_style
#show: diagram_style

#figure(
  diagram(
    node-stroke: 1pt,
    node-fill: rgb("#e9e9e9"),
    node-corner-radius: 3pt,
    node((0,0), name: <threshold>, [
      *`ProductThresholdBrake`*
      #align(left)[
        `+ threshold : double` \
        `+ initial_mass : double`
      ]
    ]),
    node((0.75,0), name: <fixed-step>, [
      *`FixedStepBrake`*
      #align(left)[
        `+ steps : size_t`
      ]
    ]),
    node((-0.75,0), name: <fixed-time>, [
      *`FixedTimeBrake`*
      #align(left)[
        `+ t_end : double`
      ]
    ]),
    node((0,1), name: <interface>, [
      `<<interface>>` \
      *`IBrake`*
      #align(left)[
        `+ shouldBrake(s: SolverState) : bool`
      ]
    ]),
    
    edge(<fixed-step>, <interface>, "--|>"),
    edge(<threshold>, <interface>, "--|>"),
    edge(<fixed-time>, <interface>, "--|>"),
  ),
  caption: [ UML klasių diagrama, reakcijos stabdymo strategijos sąsaja ir naudojamos realizacijos ]
) <brake-component-diagram>