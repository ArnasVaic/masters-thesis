// Visible placeholders for text the author still has to write in their own words.
// Search for "todo" before submitting, none of these should remain.

// A highlighted block in the body text
#let todo(body) = block(
  fill: rgb("#fff3b0"),
  stroke: (left: 3pt + rgb("#e0a800")),
  inset: 8pt,
  width: 100%,
  breakable: true,
)[*TODO:* #body]

// A highlighted inline note, e.g. for a figure caption
#let todo-inline(body) = highlight(fill: rgb("#fff3b0"))[*TODO:* #body]
