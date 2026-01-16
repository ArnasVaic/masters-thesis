// This template was built to fulfill the formal requirements of Vilnius University, department of computational and data modelling.
// The requirements can be found here: https://mif.vu.lt/lt3/dokumentai/dokumentai/KOMP/Reglamentuojantys/Reikalavimai_Magistriniams_Darbams.pdf (last updated 2026-01-16)

#let vu_template(
  supervisor_declaration,
  preface: none,
  language
) = [

  #assert(
    language in ("lt", "en"),
    message: "Language must be either 'lt' or 'en'"
  )

  // 2. Darbas rašomas viena skiltimi (vienu stulpeliu).
  #set page(columns: 1)

  // 3.  Paraštės: viršuje – 20 mm, apačioje – 20 mm, kairėje – 30 mm, dešinėje – 15 mm
  #set page(
    margin: (top: 20mm, bottom: 20mm, left: 30mm, right: 15mm)
  )

  // 4. Šrifto nustatymai: Times arba Times New Roman arba Palemonas arba Libertine, 12 pt, šrifto stilius normalus (išskyrus darbo pavadinimą ir skyrių bei poskyrių pavadinimus, kur galima naudoti pajuodintą šriftą; darbo pavadinimas ir pagrindinių skyrių pavadinimai gali būti renkami didesnio dydžio raidėmis). Iliustracijų ir lentelių pavadinimuose (trumpuose aprašymuose prie iliustracijos arba lentelės) galima naudoti mažesnio dydžio raides.
  #set text(font: "Libertinus Serif", size: 12pt);

  // Intervalas tarp teksto eilučių: 1.1 (10% didesnis už standartinį viengubą intervalą).
  #set text(spacing: 1.1em)

  // Puslapiai numeruojami viršuje arba apačioje, dešinėje pusėje
  #set page(numbering: "1", number-align: right + bottom)

  // Pagrindinės darbą sudarančios dalys (darbe eina viena po kitos būtent tokia tvarka): 
  // - susitikimų su darbo vadovu deklaracija (rekomenduojama pateikti), 
  // turinys, 
  // - pratarmė (jeigu yra), 
  // - sutartinis terminų sąrašas (jeigu yra), 
  // - anotacija lietuvių kalba, 
  // - anotacija anglų kalba (summary), 
  // - įvadas, 
  // - kiekvienas skyrius (1-asis, 2-asis ir t. t.), 
  // - išvados ir rekomendacijos, 
  // - ateities tyrimų planas arba gairės, 
  // - literatūros sąrašas, 
  // - darbo priedai (jeigu yra) pradedamos naujame puslapyje. 
  // Einamąjį skyrių sudarantys poskyriai ir skirsniai (1.1, 1.2, 1.2.1, 1.3 ir t. t.) neturi būti priverstinai pradedami naujame puslapyje.

  #supervisor_declaration

  #pagebreak(true)

  #let outline-title = if language = "lt" { "Turinys" } else { "Contents" }
  #heading(numbering: none, outlined: false, outline-title)
  #outline(depth: 3)

  #if preface != none { preface }

  #if keywords-and-notations != none { keywords-and-notations }

  // Headings
  #set heading(numbering: "1.1.1")
  #show heading.where(level: 1): set text(size: 14pt)
  #show heading: set text(weight: "bold")
  
  #set text(spacing: 1.1em)

  #doc
]