#import "config/layout.typ"
#import "config/fonts.typ"
#import "config/headings.typ"
#import "config/floats.typ"
#import "config/toc.typ"
#import "config/bibliography.typ"

#import "frontmatter/titlepage.typ": title_page

#title_page(
  "Kompiuterinio modeliavimo antro kurso magistro baigiamasis darbas",
  [ 
    Medžiagų maišymo kompiuterinis modeliavimas cheminėse reakcijose \ #text(size: 10pt)[Computer modeling of material mixing in chemical reactions] ],
  "Arnas Vaicekauskas",
  "asist. dr. Rokas Astrauskas",
  in-lithuanian: true,
)

#pagebreak()
#import "frontmatter/abstract-lt.typ"
#pagebreak()
#import "frontmatter/abstract-en.typ"

#pagebreak()
#outline(
)

#pagebreak()
#import "chapters/introduction.typ"
#import "chapters/chapter1.typ"

#pagebreak()
#import "backmatter/references.typ"

#pagebreak()
#import "backmatter/appendices.typ"
