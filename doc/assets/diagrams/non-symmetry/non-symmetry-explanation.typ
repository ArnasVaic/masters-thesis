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
        rect((0, 0), (h, h), fill: hatched, stroke: (dash: "dashed"))
        rect((0, 0), (-h, -h), fill: hatched, stroke: (dash: "dashed"))
        rect((-h, -h), (h, h))
      })

      content("c1", anchor: "south", padding: h + .2, [$c_1$])

      // C2
      group(name: "c2", {
        translate(x: 0, y: -(spacing.y + h))
        rect((0, 0), (-h, h), fill: hatched, stroke: (dash: "dashed"))
        rect((0, 0), (h, -h), fill: hatched, stroke: (dash: "dashed"))
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
        rect((0, 0), (h, h), fill: hatched, stroke: (dash: "dashed"))
        rect((0, 0), (-h, -h), fill: hatched, stroke: (dash: "dashed"))
        rect((-h, -h), (h, h))
      })

      content("c1", anchor: "south", padding: h + .2, [$c_1$])

      // C3
      group(name: "c3", {
        translate(x: 0, y: -(spacing.y + h))

        let p = 0.
        let w = 0.1

        // For coloring the interior
        set-style(stroke: none)
        merge-path(
          close: true,
          fill: hatched,
          {
            bezier((-h, w), (-w, h), (-p, w), (-w, p))
            bezier((w, h), (h, w), (w, p), (p, w))
            bezier((h, -w), (w, -h), (p, -w), (w, -p))
            bezier((-w, -h), (-h, -w), (-w, -p), (-p, -w))
          },
        )

        set-style(stroke: (dash: "dashed"))
        bezier((w, h), (h, w), (w, p), (p, w))
        bezier((-w, -h), (-h, -w), (-w, -p), (-p, -w))
        set-style(stroke: (dash: "solid"))
        bezier((-h, w), (-w, h), (-p, w), (-w, p))
        bezier((h, -w), (w, -h), (p, -w), (w, -p))

        rect((-h, -h), (h, h))
      })

      content("c3", anchor: "south", padding: h + .2, [$c_3$])

      // C4
      group(name: "c4", {
        translate(x: 2 * h + spacing.x, y: h + spacing.y)

        let w = 0.3

        // merge-path(
        //   close: true,
        //   fill: hatched,
        //   {
        //     arc((h, 0), start: 90deg, delta: 90deg, radius: h)
        //     line((0, -h), (w, -h))
        //     arc((w, -h), start: 180deg, delta: -90deg, radius: h - w)
        //     // line((-h, w), (-h, 0))
        //   },
        // )

        // merge-path(
        //   close: true,
        //   fill: hatched,
        //   {
        //     arc((-h, 0), start: -90deg, delta: 90deg, radius: h)
        //     line((0, h), (-w, h))
        //     arc((-w, h), start: 0deg, delta: -90deg, radius: h - w)
        //     line((-h, w), (-h, 0))
        //   },
        // )

        rect((-h, -h), (h, h))
      })

      content("c4", anchor: "south", padding: h + .2, [$c_4$])

      // C3'
      group(name: "c3'", {
        translate(x: 2 * h + spacing.x, y: -(h + spacing.y))

        let w = 0.3

        // merge-path(
        //   close: true,
        //   fill: hatched,
        //   {
        //     arc((h, 0), start: 90deg, delta: 90deg, radius: h)
        //     line((0, -h), (w, -h))
        //     arc((w, -h), start: 180deg, delta: -90deg, radius: h - w)
        //     // line((-h, w), (-h, 0))
        //   },
        // )

        // merge-path(
        //   close: true,
        //   fill: hatched,
        //   {
        //     arc((-h, 0), start: -90deg, delta: 90deg, radius: h)
        //     line((0, h), (-w, h))
        //     arc((-w, h), start: 0deg, delta: -90deg, radius: h - w)
        //     line((-h, w), (-h, 0))
        //   },
        // )

        rect((-h, -h), (h, h))
      })

      content("c3'", anchor: "south", padding: h + .2, [$c'_3$])

      // // ->
      group(name: "1-4", {
        // Arrow geometry: endpoints and control points
        let padding = 0.2
        let p0 = (rel: (padding, 0), to: "c1.east")
        let p3 = (rel: (-padding, 0), to: "c4.west")

        let p1 = (rel: (1, 0), to: p0)
        let p2 = (rel: (-1, 0), to: p3)

        // Show the control polygon
        set-style(stroke: (paint: gray, thickness: 0.5pt, dash: "dashed"))
        line(p0, p1, p2, p3)

        // Show control points
        set-style(fill: red, stroke: none)
        circle(p1, radius: 0.04)
        circle(p2, radius: 0.04)

        // Draw the actual arrow
        bezier(p0, p3, p1, p2)

        set-style(
          stroke: black,
          mark: (end: ">", fill: black),
        )

        bezier(p3, p3, p1, p2)
      })

      group(name: "3-4", {
        // Arrow geometry: endpoints and control points
        let padding = 0.2
        let p0 = (rel: (padding, 0), to: "c3.east")
        let p3 = (rel: (-padding, 0), to: "c4.west")

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
