#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#set par(first-line-indent: 0pt)

#figure(
  diagram(
    node-stroke: 1pt,
    node-fill: rgb("#eeddff"),
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
    node((0,0.5), name: <interface>, [
      *`ITimeStep`*
      #align(left, [
        #raw("getTimestep(): double") \
        #raw("advance(s: SolverState)")
      ])
    ]),
    
    edge(<fixed>, <interface>, "-|>"),
    edge(<exp>, <interface>, "-|>"),
  ),
  caption: [ Laiko žingsnio strategijos sąsaja (_angl. interface_) ir galimos realizacijos ]
) <timestep>