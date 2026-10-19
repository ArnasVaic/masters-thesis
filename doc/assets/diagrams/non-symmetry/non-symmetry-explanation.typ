#import "@preview/cetz:0.5.1": canvas, draw
#import "@preview/modpattern:0.2.0": *

#import "../../../config/diagram.typ": diagram_style
#show: diagram_style

#figure(
  canvas({
    import draw: *

    // half the width of a square
    let h = 1
    let spacing = (x: 2, y: 0.5)
    let hatched = modpattern(
      size: (.1cm, .1cm),
      std.line(start: (0%, 100%), end: (100%, 0%), stroke: (paint: gray, thickness: 0.5pt)),
    )

    // C1 + C2 -> C3
    scope({
      // C1
      group(name: "c1", {
        translate(x: 0, y: spacing.y + h)
        rect((0, 0), (h, h), fill: hatched)
        rect((0, 0), (-h, -h), fill: hatched)
        rect((-h, -h), (h, h))
      })

      content("c1", anchor: "south", padding: h + .2, [$c_1$])

      // C2
      group(name: "c2", {
        translate(x: 0, y: -(spacing.y + h))
        rect((0, 0), (-h, h), fill: hatched)
        rect((0, 0), (h, -h), fill: hatched)
        rect((-h, -h), (h, h))
      })

      content("c2", anchor: "south", padding: h + .2, [$c_2$])

      // C3
      group(name: "c3", {
        translate(x: 2 * h + spacing.x, y: 0)

        merge-path(
          close: true,
          fill: hatched,
          {
            let p = 0.
            let w = 0.1
            bezier((-h, w), (-w, h), (-p, w), (-w, p))
            bezier((w, h), (h, w), (w, p), (p, w))
            bezier((h, -w), (w, -h), (p, -w), (w, -p))
            bezier((-w, -h), (-h, -w), (-w, -p), (-p, -w))
          },
        )

        set-style(stroke: black, fill: none)
        rect((-h, -h), (h, h))
      })

      content("c3", anchor: "south", padding: h + .2, [$c_3$])

      // // ->
      group(name: "1-3", {
        // Arrow geometry: endpoints and control points
        let padding = 0.2
        let p0 = (rel: (padding, 0), to: "c1.east")
        let p3 = (rel: (-padding, 0), to: "c3.west")

        let p1 = (rel: (1, 0), to: p0)
        let p2 = (rel: (-1, 0), to: p3)

        // Show the control polygon
        // set-style(stroke: (paint: gray, thickness: 0.5pt, dash: "dashed"))
        // line(p0, p1, p2, p3)

        // // Show control points
        // set-style(fill: red, stroke: none)
        // circle(p1, radius: 0.04)
        // circle(p2, radius: 0.04)

        // Draw the actual arrow
        set-style(
          stroke: black,
          mark: (end: ">", fill: black),
        )
        bezier(p0, p3, p1, p2)
      })

      group(name: "2-3", {
        // Arrow geometry: endpoints and control points
        let padding = 0.2
        let p0 = (rel: (padding, 0), to: "c2.east")
        let p3 = (rel: (-padding, 0), to: "c3.west")

        let p1 = (rel: (1, 0), to: p0)
        let p2 = (rel: (-1, 0), to: p3)

        // // Show the control polygon
        // set-style(stroke: (paint: gray, thickness: 0.5pt, dash: "dashed"))
        // line(p0, p1, p2, p3)

        // // Show control points
        // set-style(fill: red, stroke: none)
        // circle(p1, radius: 0.04)
        // circle(p2, radius: 0.04)

        // Draw the actual arrow
        set-style(
          stroke: black,
          mark: (end: ">", fill: black),
        )
        bezier(p0, p3, p1, p2)
      })
    })

    // C1 + C3 -> C4
    scope({
      translate(x: 7 * h, y: 0)

      // C1
      group(name: "c1", {
        translate(x: 0, y: spacing.y + h)
        rect((0, 0), (h, h), fill: hatched)
        rect((0, 0), (-h, -h), fill: hatched)
        rect((-h, -h), (h, h))
      })

      content("c1", anchor: "south", padding: h + .2, [$c_1$])

      // C2
      group(name: "c2", {
        translate(x: 0, y: -(spacing.y + h))
        rect((0, 0), (-h, h), fill: hatched)
        rect((0, 0), (h, -h), fill: hatched)
        rect((-h, -h), (h, h))
      })

      content("c2", anchor: "south", padding: h + .2, [$c_2$])

      // C3
      group(name: "c3", {
        translate(x: 2 * h + spacing.x, y: 0)

        merge-path(
          close: true,
          fill: hatched,
          {
            let p = 0.
            let w = 0.1
            bezier((-h, w), (-w, h), (-p, w), (-w, p))
            bezier((w, h), (h, w), (w, p), (p, w))
            bezier((h, -w), (w, -h), (p, -w), (w, -p))
            bezier((-w, -h), (-h, -w), (-w, -p), (-p, -w))
          },
        )

        set-style(stroke: black, fill: none)
        rect((-h, -h), (h, h))
      })

      content("c3", anchor: "south", padding: h + .2, [$c_3$])

      // // ->
      group(name: "1-3", {
        // Arrow geometry: endpoints and control points
        let padding = 0.2
        let p0 = (rel: (padding, 0), to: "c1.east")
        let p3 = (rel: (-padding, 0), to: "c3.west")

        let p1 = (rel: (1, 0), to: p0)
        let p2 = (rel: (-1, 0), to: p3)

        // Show the control polygon
        // set-style(stroke: (paint: gray, thickness: 0.5pt, dash: "dashed"))
        // line(p0, p1, p2, p3)

        // // Show control points
        // set-style(fill: red, stroke: none)
        // circle(p1, radius: 0.04)
        // circle(p2, radius: 0.04)

        // Draw the actual arrow
        set-style(
          stroke: black,
          mark: (end: ">", fill: black),
        )
        bezier(p0, p3, p1, p2)
      })

      group(name: "2-3", {
        // Arrow geometry: endpoints and control points
        let padding = 0.2
        let p0 = (rel: (padding, 0), to: "c2.east")
        let p3 = (rel: (-padding, 0), to: "c3.west")

        let p1 = (rel: (1, 0), to: p0)
        let p2 = (rel: (-1, 0), to: p3)

        // // Show the control polygon
        // set-style(stroke: (paint: gray, thickness: 0.5pt, dash: "dashed"))
        // line(p0, p1, p2, p3)

        // // Show control points
        // set-style(fill: red, stroke: none)
        // circle(p1, radius: 0.04)
        // circle(p2, radius: 0.04)

        // Draw the actual arrow
        set-style(
          stroke: black,
          mark: (end: ">", fill: black),
        )
        bezier(p0, p3, p1, p2)
      })
    })
  }),
  caption: [ ],
) <non-symmetry-examples>

aaa
