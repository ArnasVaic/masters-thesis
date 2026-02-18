#let heading_styles() = {

  // 
  set heading(numbering: "1.")

  // Req. R3.4
  show title:   set text(weight: "bold")
  show heading: set text(weight: "bold")

  // Req. R3.5
  show title:                   set text(size: 17.28pt)
  show heading.where(level: 1): set text(size: 17.28pt)
  show heading.where(level: 2): set text(size: 14.4pt)

  show heading: it => block(
    if it.numbering != none {
      counter(heading).display(it.numbering)
      h(1em)
    }
    + it.body
  )
}
