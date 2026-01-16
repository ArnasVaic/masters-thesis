#let heading-style(doc) = [
  #set heading(numbering: "1.1.1")
  #show heading.where(level: 1): set text(size: 14pt)
  #show heading: set text(weight: "bold")
  #doc
]