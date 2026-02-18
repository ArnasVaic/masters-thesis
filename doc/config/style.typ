#import "page.typ"

#let vu_template_style_config(lang) = (doc) => {
  
  assert(
    lang == "lt" or lang == "en", 
    message: "Language has to be either 'lt' or 'en'" 
  )

  show: page_config
  show: bibliography_config(lang)


  // Custom headings:
  // Numbering + h space + name
  show heading: it => block(
    if it.numbering != none {
      counter(heading).display(it.numbering)
      h(1em)       // space *only if numbered*
    }
    + it.body       // title text always
  )

  // First line is idented
  set par(
    first-line-indent: (amount: 1.5em, all: true)
  )


  doc
}