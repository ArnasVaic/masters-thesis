#import "utils.typ": get_supplement

#let figure_config(lang) = body =>  {

  set figure.caption(separator: ".")

  // Req. R10
  show figure.where(
    kind: image
  ): set figure.caption(position: bottom)

  // Req. R11
  show figure.where(
    kind: table
  ): set figure.caption(position: top)

  // Req. R12
  show figure.where(
    kind: raw
  ): set figure.caption(position: top)

  // Req. R13.1
  show figure.where(kind: image): set figure(supplement: 
    if lang == "lt" { "pav" } else if lang == "en" { "Figure" }
  )

  // Req. R13.2
  show figure.where(kind: table): set figure(supplement: 
    if lang == "lt" { "lentelė" } else if lang == "en" { "Table" }
  )

  // Req. R13.2
  show figure.where(kind: raw): set figure(supplement: 
    if lang == "lt" { "išeities kodas" } else if lang == "en" { "Listing" }
  )

  // Req. R13.4
  show figure.caption: it => {
    if lang == "lt" {
      it.counter.display(it.numbering)
      " "
      it.supplement
      it.separator
      // Typst only automatically adds space after separator if figure kind is table 
      if it.kind == image or it.kind == raw { " " }
      it.body
    } else {
      it.supplement
      " "
      it.counter.display(it.numbering)
      it.separator
      // Typst only automatically adds space after separator if figure kind is table 
      if it.kind == image or it.kind == raw { " " }
      it.body
    } 
  }

  // Aux. Caption alignment is center by default
  show figure.caption: set align(left)

  // Aux. Caption justification is off by default
  show figure.caption: it => {
    set par(justify: true)
    it
  }

  body
}