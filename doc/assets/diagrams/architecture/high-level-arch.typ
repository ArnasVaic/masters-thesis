#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#import "../../../config/diagram.typ": diagram_style
#show: diagram_style

#figure(
  diagram(
    node-fill: rgb("#d5d5d6"),
    node-corner-radius: 3pt,
    node-stroke: 1pt,
    node-inset: 10pt,
    node((0,0), [
      *yag_model*
      #linebreak()
      (įgyvendinta C++)
    ], name: <solver>),
    node((1,-0.75), [
      *yag_model.so*
      #linebreak()
      (shared object)
    ], name: <shared-obj>),
    node((2,0), [
      *python užrašinės*
      #linebreak()
      (rezultatų analizė)
    ], name: <python>),
    edge(<solver>, <shared-obj>, "-|>", label: "kompiliuojasi į"),
    edge(<python>, <shared-obj>, "-|>", label: "naudoja")
  ),
  caption: [Aukšto lygio skaičiavimų vykdymo diagrama,.]
) <high-level-solver-arch>