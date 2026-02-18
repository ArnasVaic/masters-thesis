#let heading_config = body => {

  // Req. R3.4
  show title:   set text(weight: "bold")
  show heading: set text(weight: "bold")

  // Req. R3.5
  show title:                   set text(size: 17.28pt)
  show heading.where(level: 1): set text(size: 17.28pt)
  show heading.where(level: 2): set text(size: 14.4pt)

  // Req. R4
  show heading: set block(below: 1.1 * 1em)

  // Req. R9.1
  set heading(numbering: "1.")

  // Req. R16
  show heading: it => block(
    if it.numbering != none {
      counter(heading).display(it.numbering)
      h(1em)
    }
    + it.body
  )

  body
}
