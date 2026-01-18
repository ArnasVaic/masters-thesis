#let origin_text(in-lithuanian) = { 
  if in-lithuanian [
    VILNIAUS UNIVERSITETAS \
    MATEMATIKOS IR INFORMATIKOS FAKULTETAS \
    INFORMATIKOS INSTITUTAS \
    KOMPIUTERINIO IR DUOMENŲ MODELIAVIMO KATEDRA
  ] else [
    VILNIUS UNIVERSITY \
    FACULTY OF MATHEMATICS AND INFORMATICS \
    INSTITUTE OF COMPUTER SCIENCE \
    DEPARTMENT OF COMPUTATIONAL AND DATA MODELING
  ]
}

#let authors_block(author, in-lithuanian) = {
  let author_info = { 
    if in-lithuanian { "Atliko:" } else { "Done by:" } 
    linebreak()
    author 
    h(2cm)
    text(size: 6pt)[parašas]
  }
  // All the author information is on the right
  grid(columns: (50%, 40%), gutter: 0pt, [], author_info)
}

#let supervisor_block(supervisor, in-lithuanian) = {
  let supervisor_info = { 
    if in-lithuanian { "Vadovas:" } else { "Supervisor:" } 
    linebreak()
    supervisor 
  }
  // All the supervisor information is on the right
  grid(columns: (50%, 40%), gutter: 0pt, [], supervisor_info)
}

#let title_page(
  report_type, 
  title, 
  author, 
  supervisor, 
  in-lithuanian: true
) = {
  set page(header: none, footer: none)
  align(center, {
    image("../assets/logos/vu_logo.svg", width: 2cm)
    origin_text(in-lithuanian)
    v(4cm)
    report_type
    v(0.5cm)
    text(size: 18pt, weight: "bold")[#title]
  })
  v(4cm)
  authors_block(author, in-lithuanian)
  v(0.5cm) 
  supervisor_block(supervisor, in-lithuanian)
  v(1fr)
  align(center)[
    Vilnius \
    #datetime.year(datetime.today())
  ]
}

