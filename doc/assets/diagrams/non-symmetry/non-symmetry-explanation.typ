#import "@preview/cetz:0.5.1": canvas, draw
#import "@preview/fancy-tiling:1.0.0": *

#import "../../../config/diagram.typ": diagram_style
#show: diagram_style

#set text(font: ("Your Main Font", "Noto Color Emoji"))

#figure(
  canvas({
    import draw: *

    let w = 3

    // -------------------------------
    // C1 + C2 -> C3
    // -------------------------------
    // C1
    content((w/2, 1.2 * w), [$c_1$])
    set-style(stroke: none, fill:         diagonal-stripes(
      stripe-color: gray
    ))
    rect((0, 0), (w/2, w/2))
    rect((w/2, w/2), (w, w))
    set-style(fill: none, stroke: black)
    rect((0, 0), (w, w))
    line((w/2, 0), (w/2, w))
    line((0, w/2), (w, w/2))
    // C2
    let p2 = (0, -4)
    content((p2.at(0) + w/2, p2.at(1) + 1.2 * w), [$c_2$])
    set-style(stroke: none, fill:         diagonal-stripes(
      stripe-color: gray
    ))
    rect((p2.at(0), p2.at(1)), (p2.at(0) + w/2, p2.at(1) + w/2))
    rect((p2.at(0) + w/2, p2.at(1) + w/2), (p2.at(0) + w, p2.at(1) + w))
    set-style(fill: none, stroke: black)
    rect(p2, (p2.at(0) + w, p2.at(1) + w))
    line((p2.at(0) + w/2, p2.at(1)), (p2.at(0) + w/2, p2.at(1) + w))
    line((p2.at(0), p2.at(1) + w/2), (p2.at(0) + w, p2.at(1) + w/2))
    // -> 
    
    
  }),
  caption: [ ]
) <non-symmetry-examples>

aaa
