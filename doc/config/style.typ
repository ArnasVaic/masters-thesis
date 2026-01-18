// This template was built to fulfill the formal stylistic requirements of Vilnius University, department of computational and data modelling. Structural requirements are part of the document defined in thesis.typ.
// The requirements can be found here: https://mif.vu.lt/lt3/dokumentai/dokumentai/KOMP/Reglamentuojantys/Reikalavimai_Magistriniams_Darbams.pdf (last updated 2026-01-16)

#let vu_template_style_config(doc) = [
  
  // 2. Darbas rašomas viena skiltimi (vienu stulpeliu).
  #set page(columns: 1)

  // 3.  Paraštės: viršuje – 20 mm, apačioje – 20 mm, kairėje – 30 mm, dešinėje – 15 mm
  #set page(
    margin: (top: 20mm, bottom: 20mm, left: 30mm, right: 15mm)
  )

  // 4. Šrifto nustatymai: Times arba Times New Roman arba Palemonas arba Libertine, 12 pt, šrifto stilius normalus (išskyrus darbo pavadinimą ir skyrių bei poskyrių pavadinimus, kur galima naudoti pajuodintą šriftą; darbo pavadinimas ir pagrindinių skyrių pavadinimai gali būti renkami didesnio dydžio raidėmis). Iliustracijų ir lentelių pavadinimuose (trumpuose aprašymuose prie iliustracijos arba lentelės) galima naudoti mažesnio dydžio raides.
  #set text(font: "Libertinus Serif", size: 12pt);
  #show heading.where(level: 1): set text(size: 14pt)
  #show heading: set text(weight: "bold")

  // Intervalas tarp teksto eilučių: 1.1 (10% didesnis už standartinį viengubą intervalą).
  #set par(spacing: 2em)

  // Puslapiai numeruojami viršuje arba apačioje, dešinėje pusėje
  #set page(numbering: "1", number-align: right + bottom)

  // Pagrindinės darbą sudarančios dalys (darbe eina viena po kitos būtent tokia tvarka): 
  // - susitikimų su darbo vadovu deklaracija (rekomenduojama pateikti), 
  // - turinys, 
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
  #set heading(numbering: "1.1.1")
  
  // Susitikimų su darbo vadovu deklaracija (rekomenduojama pateikti) viešinant darbą neturi būti matoma, todėl elektroninėje darbo versijoje šią deklaraciją pateikite atskiroje byloje. Ji neminima darbo turinyje, neturi puslapio numerio ir neįtakoja darbo puslapių numeracijos.

  // Literatūros sąrašas numeruojamas skaičiais, abėcėlės tvarka (pagal pirmojo autoriaus pavardę, jei ji sutampa, atsižvelgiama į kitų autorių pavardes, pavadinimą). Literatūros šaltiniais gali būti: knygos, straipsniai, studentų bakalauriniai ir magistriniai darbai, internete patalpinta medžiaga. Literatūros sąraše privalo būti bent penki šaltiniai iš knygų ir straipsnių kategorijos (pagal galimybes stenkitės remtis naujausiais šaltiniais). Visos literatūros sąrašo pozicijos privalo būti cituojamos darbo tekste. Literatūros sąrašas privalo būti apiformintas ir cituojamas taip, kaip pateiktame pavyzdyje [2] (žr. „Rašto darbai”).
  #set bibliography(
    style: "plain.csl",
    full: false,
    title: "Literatūros šaltiniai"
  )

  //  Iliustracijos, lentelės ir pseudokodas privalo tenkinti reikalavimus, nurodytus [2] (žr. „Rašto darbai”
  // TODO: the link for this reference in the university page doesn't work so I no idea what are the requirements. Will need to update once I get feedback from university about this.
  
  // Titulinis puslapis apipavidalinamas, kaip parodyta pavyzdyje [2] (žr. „Rašto darbai”)
  // Title page is configured in config/titlepage.typ

  // Nenumeruojami: turinys, pratarmė, sutartinis terminų sąrašas (jeigu yra), anotacija lietuvių kalba, anotacija anglų kalba (summary), įvadas, išvados ir rekomendacijos, ateities tyrimų planas arba gairės ir literatūros sąrašas. Priedai numeruojami atskirai didžiosiomis lotyniškomis raidėmis (A, B, C ir t. t.).
  // Structure is configured in thesis.typ
  
  #doc
]