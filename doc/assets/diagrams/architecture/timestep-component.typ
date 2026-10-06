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
    node((1,0), name: <exp>, [
      *`GeometricTimeStep`*
      #align(left)[
        `+ dt_0 : double` \
        `+ r : double`
      ]
    ]),
    node((0,0.5), name: <interface>, [
      `<<interface>>` \
      *`ITimeStep`*
      #align(left)[
        `+ getTimestep() : double` \
        `+ advance(s : SolverState)`
      ]
    ]),
    
    edge(<fixed>, <interface>, "--|>"),
    edge(<exp>, <interface>, "--|>"),
  ),
  caption: [ UML klasių diagrama, laiko žingsnio strategijos sąsaja (_angl. interface_) ir galimos realizacijos ]
) <timestep-component-diagram>