#import "config/style.typ": vu_template_style_config
#import "config/titlepage.typ": title_page

#import "frontmatter/abstract-lt.typ": 

#show: vu_template_style_config

#title_page(
  "Kompiuterinio modeliavimo antro kurso magistro baigiamasis darbas",
  [ 
    Medžiagų maišymo kompiuterinis modeliavimas cheminėse reakcijose \ #text(size: 10pt)[Computer modeling of material mixing in chemical reactions] ],
  "Arnas Vaicekauskas",
  "asist. dr. Rokas Astrauskas",
  in-lithuanian: true,
)

#heading(numbering: none, outlined: false, "Turinys")
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

#include "chapters/chapter1.typ"

#pagebreak(weak:true)

#include "backmatter/conclusions.typ"

#pagebreak(weak:true)

#include "backmatter/future_plans.typ"

#pagebreak(weak:true)

#include "backmatter/appendices.typ"

#pagebreak(weak:true)

#bibliography("references.bib")