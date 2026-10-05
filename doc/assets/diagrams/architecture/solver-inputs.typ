#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "../../../config/diagram.typ": diagram_style
#show: diagram_style

#figure(
  diagram(
    node-stroke: 1pt,
    node-fill: rgb("#e9e9e9"),
    node-corner-radius: 3pt,
    node((0, 0), name: <disc>, width: 180pt, [
      *`Discretization`*
      #align(left)[
      `+ physical_space_w : double` \
      `+ physical_space_h : double` \
      `+ mesh_resolution_x : size_t` \
      `+ mesh_resolution_y : size_t` \
      `+ dx : double` \
      `+ dy : double`
    ]]),
    node((1, 0), name: <model-params>, [
      *`ModelParameters`*
      #align(left)[
        `+ D : double[5]` \
        `+ k : double[3]`
    ]]),
    node((-1, 0), name: <intial-condition>, width: 130pt, [
      *`SolutionState`*
      #align(left)[
        `+ c1 : double[][]` \
        `+ c2 : double[][]` \
        `+ c3 : double[][]` \
        `+ c4 : double[][]` \
        `+ c5 : double[][]`
      ]
    ])

  ),
  caption: [ UML klasių diagrama, pagrindinės sprendiklio konfigūracinės klasės -- sprendinio būsena (`SolutionState`), erdvės diskretizacija (`Discretization`) ir fizinės modelio konstantos (`ModelParameters`). ]
) <solver-inputs-diagram>