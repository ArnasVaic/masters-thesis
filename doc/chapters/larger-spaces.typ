#import "@preview/cetz:0.5.1": canvas, draw

= Didesnių erdvių modeliavimas

Vienas iš šio tyrimo uždavinių yra surasti fizinių modelio parametrų reikšmes. Iki šiol pristatyti rezultatai buvo gauti modeliuojant mažą erdvės sritį, kuri kaip jau minėta yra stipriai idealizuota ir gali lemti, kad rasti parametrai nebus tokie tikslūs kokie galėtų būti. Dėl to apsvarstysime ir kitokias, didesnes pradines sąlygas.

== Padidinta pradinė salygą

Šis pavadinimas apibudina tą pačią pradinę salygą, kuria demonstravome iki šiol neapsiribojant mažu plotu. Pradinės sąlygos sukonstruotos tokiu būdu, kaip pavaizduota @larger-initial-condition, turi privalumą -- jos yra deterministiškos ir kaip pastebi straipnių autoriai @ivanauskasComputationalModellingYAG2009 jos yra periodinės, dėl ko ir užtenka modeliuoti mažiausiąją sritį, kur $n=1$. Svarbu pastebėti, kad didinant erdvės dydį didžiausias atstumas tarp skirtingų medžiagų išlieka toks pat -- būtent tai lemia, kad reakcija užtrunka beveik tiek pat laiko nepriklausomai nuo modeliuojamos erdvės dydžio. Šis privalumas yra aktualus tik tada, jei bandome sutaupyti skaičiavimo resursų, tačiau analitine prasme deterministiška pradinė sąlyga nėra ypač įdomi.

// n whole particles per side, the outermost rows and columns are cut in half
// like in the domain of the initial-condition figure (n = 1 is that same 2 x 2 domain)
#let perfect-ic(n) = canvas({
  let side = 3.2
  let unit = side / n
  let color = rgb("dededeff")
  let pad = 0.3
  let mark = (start: ">", end: ">", fill: black, scale: 0.7)

  let strip(i) = (
    if i == 0 { 0 } else { i - 0.5 },
    if i == n { n } else { i + 0.5 },
  )

  for i in range(n + 1) {
    for j in range(n + 1) {
      let (x0, x1) = strip(i)
      let (y0, y1) = strip(j)
      draw.rect(
        (x0 * unit, y0 * unit),
        (x1 * unit, y1 * unit),
        stroke: 1pt,
        fill: if calc.odd(i + j) { color } else { none },
      )
    }
  }

  draw.line((0, side + pad), (side, side + pad), mark: mark, stroke: 0.75pt)
  draw.content((side / 2, side + pad), anchor: "south", padding: 0.12, $#n mu m$)

  draw.line((-pad, 0), (-pad, side), mark: mark, stroke: 0.75pt)
  draw.content((-pad, side / 2), anchor: "east", padding: 0.12, $#n mu m$)

  draw.content((side / 2, 0), anchor: "north", padding: 0.25, $n = #n$)
})

#figure(
  grid(
    columns: (1fr, 1fr, 1fr),
    align: center + bottom,
    ..(1, 2, 4).map(perfect-ic),
  ),
  caption: [ Padidintos pradinės sąlygos vizualizacija. ],
) <larger-initial-condition>