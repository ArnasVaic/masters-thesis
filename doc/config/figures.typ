#let figure_config(lang: str) = {

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
    kind: code
  ): set figure.caption(position: top)

  // Req. R13.1, R13.2, R13.3
  set figure(supplement: it => get_supplement(it, lang))

  // // Req. R13.1
  // show figure.where(kind: image): set figure(supplement: 
  //   if lang == "lt" 
  //     [ pav. ] 
  //   else if lang == "en"
  //     [ Fig. ]
  // )

  // // Req. R13.2
  // show figure.where(kind: table): set figure(supplement: 
  //  if lang == "lt" 
  //     [ lentelė. ] 
  //   else if lang == "en"
  //     [ Table ]
  // )

  // // Req. R13.2
  // show figure.where(kind: code): set figure(supplement: 
  //  if lang == "lt" 
  //     [ išeities kodas. ] 
  //   else if lang == "en"
  //     [ Listing ]
  // )

  // Req. R13.4
  if lang == "lt" {
    show figure.caption: it => {
      it.counter.display(it.numbering)
      " "
      it.supplement
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
}