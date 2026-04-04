#import "config/style.typ": style_config
#import "config/titlepage.typ": title_page

#show: style_config("lt")

// Req. R6

#title_page(
  "Kompiuterinio modeliavimo antro kurso magistro baigiamasis darbas",
  [ 
    Kietafazės YAG sintezės reakcijos parametrų nustatymas kompiuteriniais modeliais \ 
    #text(size: 10pt)[Determination of reaction parameters for solid-phase YAG synthesis using computer models] 
  ],
  "Arnas Vaicekauskas",
  "asist. dr. Rokas Astrauskas",
  "lt",
)

#outline(depth: 3)

#pagebreak(weak: true)

// #import "frontmatter/preface.typ"
// #import "frontmatter/keywords-and-notation.typ"

#include "frontmatter/abstract-lt.typ"

#pagebreak(weak: true)

#include "frontmatter/abstract-en.typ"

#pagebreak(weak: true)

#include "chapters/introduction.typ"

#pagebreak(weak: true)

#include "chapters/literature.typ"

#pagebreak(weak:true)

#include "backmatter/conclusions.typ"

#pagebreak(weak:true)

#include "backmatter/future_plans.typ"

#pagebreak(weak:true)

#bibliography("references.bib")

#pagebreak(weak:true)

#include "backmatter/appendices.typ"
