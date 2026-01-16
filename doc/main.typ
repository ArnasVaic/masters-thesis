#import "config/layout.typ"
#import "config/fonts.typ"
#import "config/headings.typ": heading-style
#import "config/floats.typ"
#import "config/outline.typ": my_custom_outline
#import "config/bibliography.typ"

#import "frontmatter/titlepage.typ": title_page

#show: heading-style

#title_page(
  "Kompiuterinio modeliavimo antro kurso magistro baigiamasis darbas",
  [ 
    Medžiagų maišymo kompiuterinis modeliavimas cheminėse reakcijose \ #text(size: 10pt)[Computer modeling of material mixing in chemical reactions] ],
  "Arnas Vaicekauskas",
  "asist. dr. Rokas Astrauskas",
  in-lithuanian: true,
)

#pagebreak()
#include "frontmatter/abstract-lt.typ"
#pagebreak()
#include "frontmatter/abstract-en.typ"

#pagebreak()
#my_custom_outline()

#pagebreak()
#include "chapters/introduction.typ"
#include "chapters/chapter1.typ"

#pagebreak()
#include "backmatter/references.typ"

#pagebreak()
#include "backmatter/appendices.typ"
