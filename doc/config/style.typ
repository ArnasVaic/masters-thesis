// This template was built to fulfill the formal stylistic requirements of Vilnius University, department of computational and data modelling. Structural requirements are part of the document defined in thesis.typ.
// The requirements can be found here: https://mif.vu.lt/lt3/dokumentai/dokumentai/KOMP/Reglamentuojantys/Reikalavimai_Magistriniams_Darbams.pdf (last updated 2026-01-16)

#let vu_template_style_config(doc) = [
  
  // 10. Iliustracijos, lentelės ir pseudokodas privalo tenkinti reikalavimus, nurodytus [2] (žr. „Rašto darbai”
  // TODO: the link for this reference in the university page doesn't work so I no idea what are the requirements. Will need to update once I get feedback from university about this.
  
  // 11. Titulinis puslapis apipavidalinamas, kaip parodyta pavyzdyje [2] (žr. „Rašto darbai”)
  // Title page is configured in config/titlepage.typ and is made to look like the official LaTeX template: https://www.overleaf.com/project/60c9ac7c5cf5eefc6065666a

  
  // TODO: Priskirti konfigūracija kažkuriam tai reikalavimui
  #show ref.where(form: "normal"): set ref(supplement: it => {
    if it.func() == figure {
      "pav."   // your custom supplement
    } else {
      it.supplement  // leave others alone
    }
  })

  // Configure custom references for:
  // - Figures: x pav.
  #show ref: it => {
    let el = it.element

    if el == none or el.func() != figure { return it }
    let capt = it.element.caption

    link(
      el.location(), 
      numbering(
        el.numbering, ..counter(figure).at(el.location())
      ) + " " + el.supplement,
    )
  }

  // Configure custom figure captions:
  // x pav. <text>
  #set figure(supplement: "pav.")
  #show figure.caption: it => {
    it.counter.display(it.numbering)
    " "
    it.supplement
    it.body
  }

  // Figure caption alignment
  // TODO: probably also needed for tables
  #show figure.caption: set align(left)
  #show figure.caption: it => {
    set par(justify: true)
    it
  }

  // Custom headings:
  // Numbering + h space + name
  #show heading: it => block(
    if it.numbering != none {
      counter(heading).display(it.numbering)
      h(1em)       // space *only if numbered*
    }
    + it.body       // title text always
  )

  // First line is idented
  #set par(
    first-line-indent: (amount: 1.5em, all: true)
  )


  #doc
]