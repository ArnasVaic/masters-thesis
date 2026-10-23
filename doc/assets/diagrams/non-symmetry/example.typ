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

    // C1 + C3 -> C4
    scope({
      translate(x: 7 * h, y: 0)

      // C1
      group(name: "c1", {
        translate(x: 0, y: spacing.y + h)
        let w = 0.1
        set-style(stroke: none)
        // Bottom left
        merge-path(
          close: true,
          fill: rgb("#ff000055"),
          {
            line((0, 0), (h, 0))
            line((h, 0), (h, w))
            line((h, w), (w, w))
            line((w, w), (w, h))
            line((w, h), (0, h))
          },
        )
        // Top right
        merge-path(
          close: true,
          fill: rgb("#ff000055"),
          {
            line((0, 0), (-h, 0))
            line((-h, 0), (-h, -w))
            line((-h, -w), (-w, -w))
            line((-w, -w), (-w, -h))
            line((-w, -h), (0, -h))
          },
        )
        set-style(stroke: black)
        rect((0, 0), (h, h), fill: hatched)
        rect((0, 0), (-h, -h), fill: hatched)
        rect((-h, -h), (h, h))
      })

      content("c1", anchor: "south", padding: h + .2, [$rho_1(t = t_1)$])

      // C3
      group(name: "c3", {
        translate(x: 0, y: -(spacing.y + h))

        let p = 0.
        let w = 0.1

        // For coloring the interior
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

        set-style(stroke: none)

        merge-path(
          close: true,
          fill: rgb("#ff000055"),
          {
            let p = 0.1
            let q = 0.06
            bezier((0, h), (-h, 0), (q, -q), (q, -q))
            bezier((-h, -w), (-w, -h), (0, -p), (-p, 0))
            bezier((0, -h), (h, 0), (-q, q), (-q, q))
            bezier((h, w), (w, h), (0, p), (p, 0))
            // bezier((0, h), (-h, 0))
            // bezier((0, w), (-h, 0), (0, 0), (0, 0))
          },
        )

        set-style(stroke: (dash: "solid"))

        rect((-h, -h), (h, h))

        content((-0.6, 0.25), $triangle.filled.small.t$)
        content((-0.25, 0.6), $triangle.filled.small.l$)

        content((0.6, -0.25), $triangle.filled.small.b$)
        content((0.25, -0.6), $triangle.filled.small.r$)

      })

      content("c3", anchor: "south", padding: h + .2, [$rho_3(t = t_1)$])

      // C3'
      group(name: "c3'", {
        translate(x: 4 * h, y: -(spacing.y + h))

        let w = 0.1
        let p = 0.2

        // For coloring the interior
        merge-path(
          close: true,
          fill: hatched,
          {
            bezier((-h, w + p), (-(w + p), h), (-(p + w), w + p), (-(w + p), w + p))
            bezier((-w, h), (-h, w), (-w, p), (-p, w))
          },
        )

        merge-path(
          close: true,
          fill: hatched,
          {
            bezier((h, -(w + p)), (w + p, -h), (p + w, -(w + p)), (w + p, -(w + p)))
            bezier((w, -h), (h, -w), (w, -p), (p, -w))
          },
        )

        rect((-h, -h), (h, h))

      })

      content("c3'", anchor: "south", padding: h + .2, [$rho_3(t = t_3)$])

      // C4
      group(name: "c4", {
        translate(x: 2 * h + spacing.x, y: spacing.y + h)
        let w = 0.15
        merge-path(
          close: true,
          fill: hatched,
          {
            bezier((0, h), (-h, 0), (0, 0), (0, 0))
            bezier((-h, -w), (-w, -h), (-w, -w), (-w, -w))
            bezier((0, -h), (h, 0), (0, 0), (0, 0))
            bezier((h, w), (w, h), (w, w), (w, w))
          },
        )

        rect((-h, -h), (h, h))
      })

      content("c4", anchor: "south", padding: h + .2, [$rho_4(t = t_1)$])

      group(name: "arrow-1-3", {
        // Arrow geometry: endpoints and control points
        let padding = 0.2
        let p0 = (rel: (padding, 0), to: "c1.east")
        let p3 = (rel: (-padding, 0), to: "c4.west")

        let p1 = (rel: (1, 0), to: p0)
        let p2 = (rel: (-1, 0), to: p3)
        // Draw the actual arrow
        set-style(
          stroke: black,
          mark: (end: ">", fill: black),
        )
        bezier(p0, p3, p1, p2)
      })

      group(name: "arrow-3-4", {
        // Arrow geometry: endpoints and control points
        let padding = 0.2
        let p0 = (rel: (padding, 0), to: "c3.east")
        let p3 = (rel: (-padding, 0), to: "c4.west")
        let p1 = (rel: (1, 0), to: p0)
        let p2 = (rel: (-1, 0), to: p3)
        set-style(
          stroke: black,
          mark: (end: ">", fill: black),
        )
        bezier(p0, p3, p1, p2)
      })

      group(name: "arrow-3-3'", {
        // Arrow geometry: endpoints and control points
        let padding = 0.2
        let p0 = (rel: (padding, 0), to: "c3.east")
        let p3 = (rel: (-padding, 0), to: "c3'.west")

        let p1 = (rel: (1, 0), to: p0)
        let p2 = (rel: (-1, 0), to: p3)
        // Draw the actual arrow
        set-style(
          stroke: black,
          mark: (end: ">", fill: black),
        )
        bezier(p0, p3, p1, p2)
      })
    })

  }),
  caption: [ Reakcijos modelio dinamikos analizė -- kaip trečios medžiagos tankio pasiskirstyme $rho_3$ susiformuoja atsiskyrę žiedai. Įstrižu raštu padengtas plotas žymi erdvę, kurioje yra didžiausias tankis. Paryškintas plotas žymi persidengiančias medžiagų tankių sritis, kuriose reakcija vyksta sparčiausiai. Juodi trikampiai žymi difuzijos kryptį. Kaip ir rezultatuose, #box($rho_i = rho_i (bold(x), t = t_n) = M_i c(bold(x), t = t_n), bold(x) in Omega$) žymi $i$-osios medžiagos tankio pasiskirstymą laiko momentu $t_n$ erdvėje $Omega$ ],
) <non-symmetry-example>
