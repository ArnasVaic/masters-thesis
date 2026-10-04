#import "@preview/fletcher:0.5.8" as fletcher
#import fletcher: draw

// A closed (hollow) triangle, unlike fletcher's built-in "|>"/"<|" which are
// filled solid. This is the standard UML generalization/implementation
// arrowhead, so it replaces "|>"/"<|" for every diagram using this style.
#let uml_triangle_draw(mark) = draw.line(
  (180deg + mark.sharpness, mark.size),
  (0, 0),
  (180deg - mark.sharpness, mark.size),
  close: true,
)

#let uml_triangle = (
  inherit: "straight",
  sharpness: 22deg,
  size: 18,
  fill: white,
  draw: uml_triangle_draw,
)

#let diagram_style = (body) => {
  set par(first-line-indent: 0pt)

  fletcher.MARKS.update(m => m + (
    "|>": uml_triangle,
    "<|": uml_triangle + (rev: true),
  ))

  body
}