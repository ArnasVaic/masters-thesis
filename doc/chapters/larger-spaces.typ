#import "@preview/cetz:0.5.1": canvas, draw

= Didesnių erdvių modeliavimas

Vienas iš šio tyrimo uždavinių yra surasti fizinių modelio parametrų reikšmes. Iki šiol pristatyti rezultatai buvo gauti modeliuojant mažą erdvės sritį, kuri kaip jau minėta yra stipriai idealizuota ir gali lemti, kad rasti parametrai nebus tokie tikslūs kokie galėtų būti. Dėl to apsvarstysime ir kitokias, didesnes pradines sąlygas.

== Padidinta pradinė salygą

Šis pavadinimas apibudina tą pačią pradinę salygą, kuria demonstravome iki šiol neapsiribojant mažu plotu. Pradinės sąlygos sukonstruotos tokiu būdu, kaip pavaizduota @larger-initial-condition, turi privalumą -- jos yra deterministiškos ir kaip pastebi straipnių autoriai @ivanauskasComputationalModellingYAG2009 jos yra periodinės, dėl ko ir užtenka modeliuoti mažiausiąją sritį, kur $n=1$. Šis privalumas yra aktualus tik tada, jei bandome sutaupyti skaičiavimo resursų, tačiau analitine prasme deterministiška pradinė sąlyga nėra ypač įdomi.

// Width and height arrows of length um and the n label around a square panel
#let ic-labels(side, um, n) = {
  let pad = 0.3
  let mark = (start: ">", end: ">", fill: black, scale: 0.7)

  draw.line((0, side + pad), (side, side + pad), mark: mark, stroke: 0.75pt)
  draw.content((side / 2, side + pad), anchor: "south", padding: 0.12, $#um mu m$)

  draw.line((-pad, 0), (-pad, side), mark: mark, stroke: 0.75pt)
  draw.content((-pad, side / 2), anchor: "east", padding: 0.12, $#um mu m$)

  draw.content((side / 2, 0), anchor: "north", padding: 0.25, $n = #n$)
}

// n whole particles per side, the outermost rows and columns are cut in half
// like in the domain of the initial-condition figure (n = 1 is that same 2 x 2 domain)
#let perfect-ic(n) = canvas({
  let side = 3.2
  let unit = side / n
  let color = rgb("dededeff")

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

  ic-labels(side, n, n)
})

#figure(
  grid(
    columns: (1fr, 1fr, 1fr),
    align: center + bottom,
    ..(1, 2, 4).map(perfect-ic),
  ),
  caption: [ Padidintos pradinės sąlygos vizualizacija. Idealizuotas homogeniško aliuminio ir itrio oksidų mišinio modelis. Plotų atspalvių skirtumas žymi, kad tai skirtingos medžiagos.],
) <larger-initial-condition>

Svarbu pastebėti, kad didinant erdvės dydį didžiausias atstumas tarp skirtingų medžiagų išlieka toks pat -- būtent tai lemia, kad reakcija užtrunka beveik tiek pat laiko nepriklausomai nuo modeliuojamos erdvės dydžio, kaip pavaizduota @larger-initial-condition-end-time 

#figure(
  image("../assets/diagrams/checkerboard-end-time.png", width: 60%),
  caption: [ Reakcijos trukmės priklausomybė nuo padidintos pradinės sąlygos dydžio $n$. Naudojami modelio parametrai: $D_i = 10^(-2) mu m^2\/s$, $k_1=10.0, k_2=5.0, k_3=1.0, "kur" [k_i] = mu m^3\/("mol" dot s)$, pradinės koncentracijos $c^0_1 = 5$ ir $c^0_2 = 3 "mol"\/mu m^3$. Naudota diskrečios erdvės rezoliucija $40n times 40n$, laiko žingsnis -- geometriškai didėjantis nuo $Delta t_0 = 10^(-4)s$ santykiu $r = 1.001$ iki ribos $Delta t_"max" = 10^(-3)s$. Reakcija laikoma pasibaigusia, kai reagentų masė sumažėja iki 10% pradinės masės.],
) <larger-initial-condition-end-time>

== Atsitiktinės išsidėščiusios idealios dalelės

Pirmasis bandymas modeliuoti nedeterministišką pradinę sąlyga yra artimas padidintai pradinei sąlygai. Šiuo atveju atsisakome dydžio ribojimo, tačiau taip pat atsisakome ir prielaidos, kad dalelės tolygiai pasiskirščiusios erdvėje -- leidžiame jom pasiskirstyti visiškai atsitiktiniu būdu kaip pavaizduota @random-squares-initial-condition

// Real arrangements of the random_rectangles builder (seed 0): one string per row from the
// bottom, 0 is a c1 particle and 1 a c2 particle. n particles of 1 um per side
#let random-ic(arrangement) = canvas({
  let rows = arrangement.split(" ")
  let side = 3.2
  let n = rows.len()
  let unit = side / n

  for (j, row) in rows.enumerate() {
    for (i, particle) in row.clusters().enumerate() {
      draw.rect(
        (i * unit, j * unit),
        ((i + 1) * unit, (j + 1) * unit),
        stroke: 0.5pt,
        fill: if particle == "1" { rgb("dededeff") } else { none },
      )
    }
  }
  draw.rect((0, 0), (side, side), stroke: 1pt)

  ic-labels(side, n, n)
})

#figure(
  grid(
    columns: (1fr, 1fr, 1fr),
    align: center + bottom,
    ..(
      "1011 1101 1000 0001",
      "10011001 01000001 10010110 00001110 11100111 11110100 11011101 01001000",
      "011101001101 110011001010 101101011110 011100010010 101010111011 101111111110 001100000011 110000011101 100101001000 000011000101 010011010110 001011001000",
    ).map(random-ic),
  ),
  caption: [
    Nedeterministinės pradinės sąlygos pavyzdžiai -- atsitiktinai išsidėščiusios idealios (kvadratinės) dalelės.
  ],
) <random-squares-initial-condition>

Galime numanyti, kad toks išsidėstymas turės stiprų poveikį vidutinei reakcijos trukmei. Kiekvienam dydžiui $n$ egzistuoja dalelių konfigūracija, kuri užtruks ilgiausiai. Nesunku sugalvoti kaip galėtų atrodyti -- norint, kad medžiagos reaguotų kuo lėčiau, reikia pasirūpinti, kad skirtingų medžiagų koncentracijos būtų kaip įmanoma toli viena nuo kitos, kaip pavaizudota @split-squares-initial-condition

// Slowest arrangement for n particles per side: the materials are fully separated,
// the lower half holds only c1 particles and the upper half only c2 particles
#let split-ic(n) = random-ic(
  range(n).map(j => (if j < n / 2 { "0" } else { "1" }) * n).join(" "),
)

#figure(
  grid(
    columns: (1fr, 1fr, 1fr),
    align: center + bottom,
    ..(4, 8, 12).map(split-ic),
  ),
  caption: [
    Itin nepalanki pradinė sąlyga -- skirtingų medžiagų dalelės visiškai atskirtos: viršutinę erdvės pusę užima viena medžiaga, o apatinę -- kita.
  ],
) <split-squares-initial-condition>

Analogiško efekto su pradinėmis sąlygomis, kurios lemtų trumpą reakcijos trukmę nėra dėl to, kad padidinta pradinė sąlyga jau yra geriausia, kurią galime sukonstruoti. Taip nutinka dėl prieš tai minėto trumpiausio atstumo tarp tolimiausių skirtingų medžiagų taškų -- difuzija yra vienintelė priemonė medžiagai judėti. Norint tuo įsitikinti, galime apskaičiuoti reakcijos trukmę daugybei skirtingų atsitiktinu būdu sudarytų pradinių sąlygų su skirtingais dydžaisi, tokiu būdu pamatytumėme kaip evoliucionuoja reakcijos trukmės pasiskirstymas priklausomai nuo erdvės dydžio $n$.