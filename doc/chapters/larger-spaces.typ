#import "@preview/cetz:0.5.1": canvas, draw
#import "../config/todo.typ": todo, todo-inline

= Didesnių erdvių modeliavimas

Vienas iš šio tyrimo uždavinių yra surasti fizinių modelio parametrų reikšmes. Iki šiol pristatyti rezultatai buvo gauti modeliuojant mažą erdvės sritį, kuri kaip jau minėta yra stipriai idealizuota ir gali lemti, kad rasti parametrai nebus tokie tikslūs kokie galėtų būti. Dėl to apsvarstysime ir kitokias, didesnes pradines sąlygas. 

== Ideali pradinė salygą

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

Svarbu pastebėti, kad didinant erdvės dydį atstumas nuo bet kurios dalelės centro iki artimiausio kitos medžiagos dalelės centro išlieka toks pat -- būtent tai lemia, kad reakcija užtrunka beveik tiek pat laiko nepriklausomai nuo modeliuojamos erdvės dydžio, kaip pavaizduota @larger-initial-condition-end-time Dėl šios priežasties tokiu būdu sukonstruotą pradinę sąlyga vadiname idealia.

#figure(
  image("../assets/diagrams/checkerboard-end-time.png", width: 60%),
  caption: [ Reakcijos trukmės priklausomybė nuo padidintos pradinės sąlygos dydžio $n$. Naudojami modelio parametrai: $D_i = 10^(-2) mu m^2\/s$, $k_1=10.0, k_2=5.0, k_3=1.0, "kur" [k_i] = mu m^3\/("mol" dot s)$, pradinės koncentracijos $c^0_1 = 5$ ir $c^0_2 = 3 "mol"\/mu m^3$. Naudota diskrečios erdvės rezoliucija $40n times 40n$, laiko žingsnis -- geometriškai didėjantis nuo $Delta t_0 = 10^(-4)s$ santykiu $r = 1.001$ iki ribos $Delta t_"max" = 10^(-3)s$. Reakcija laikoma pasibaigusia, kai reagentų masė sumažėja iki 10% pradinės masės.],
) <larger-initial-condition-end-time>

== Atsitiktinės išsidėščiusios idealios dalelės

Pirmasis bandymas modeliuoti nedeterministišką pradinę sąlyga yra artimas idealiai pradinei sąlygai. Šiuo atveju atsisakome dydžio ribojimo, tačiau taip pat atsisakome ir prielaidos, kad dalelės tolygiai pasiskirščiusios erdvėje -- leidžiame jom pasiskirstyti visiškai atsitiktiniu būdu kaip pavaizduota @random-squares-initial-condition

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

=== Nepalankios pradinės sąlygos

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
    Itin nepalanki pradinė sąlyga -- skirtingų medžiagų dalelės visiškai atskirtos: viršutinę erdvės pusę užima viena medžiaga, o apatinę -- kita. Tokios pradinės sąlygos reakcija truks ilgai dėl to, kad dominuojant reakcijai, prireiks daug laiko kol viršuje esanti medžiaga difuzijos būdu pasieks pačioje apačioje esančią medžiagą.
  ],
) <split-squares-initial-condition>

Analogiško efekto su pradinėmis sąlygomis, kurios lemtų trumpą reakcijos trukmę nėra dėl to, kad ideali pradinė sąlyga jau yra geriausia, kurią galime sukonstruoti. Taip nutinka dėl prieš tai minėto trumpiausio atstumo tarp tolimiausių skirtingų medžiagų taškų -- difuzija yra vienintelė priemonė medžiagai judėti. Norint tuo įsitikinti, galime apskaičiuoti reakcijos trukmę daugybei skirtingų atsitiktinu būdu sudarytų pradinių sąlygų su skirtingais dydžaisi, tokiu būdu pamatytumėme kaip evoliucionuoja reakcijos trukmės pasiskirstymas priklausomai nuo erdvės dydžio $n$. Rezultatai pavaizduoti @random-squares-end-time-distribution

=== Reakcijos trukmės pasiskirstymas

#figure(
  image("../assets/diagrams/random-squares-end-time-distribution.png", width: 85%),
  caption: [ Atsitiktinai išsidėsčiusių idealių dalelių reakcijos trukmės pasiskirstymas skirtingiems dydžiams $n$, kiekvienam dydžiui sumodeliuota po 1000 atsitiktinių konfigūracijų. Viršuje -- branduoliniu tankio įverčiu (_angl. kernel density estimate, KDE_) gautos pasiskirstymo kreivės, apačioje -- kiekvienos konfigūracijos reakcijos trukmė (taškai). Brūkšninės linijos ir juodi brūkšniai žymi medianas. Naudojami modelio parametrai: $D_i = 10^(-2) mu m^2\/s$, $k_1=1.0, k_2=0.5, k_3=0.1, "kur" [k_i] = mu m^3\/("mol" dot s)$, pradinės koncentracijos $c^0_1 = 5$ ir $c^0_2 = 3 "mol"\/mu m^3$. Naudota diskrečios erdvės rezoliucija $20n times 20n$, laiko žingsnis -- geometriškai didėjantis nuo $Delta t_0 = 2 dot 10^(-3)s$ santykiu $r = 1.01$ iki ribos $Delta t_"max" = 0.2s$. Reakcija laikoma pasibaigusia, kai reagentų masė sumažėja iki 10% pradinės masės.],
) <random-squares-end-time-distribution>


Akivaizdu, kad idealią pradinę sąlygą su kiekvienu erdvės dydžiu atsitiktinai sutikti darosi vis sunkiau todėl @random-squares-end-time-distribution matome, kad kairioji pasiskirstymo uodega slenkasi dešinėn su kiekvienu dydžiu $n$. Tačiau galime pastebėti ir keletą įdomių reiškinių. $n=4$ atveju pasiskirstymas turi keletą viršūnių. Norint išsiaiškinti, kodėl taip nutinka galime iš arčiau patyrinėti šį pasiskirstymą. Kalneliai pasiskirstyme sufleruoja, kad pasiskirstymas turi iš tikro slepia kelis skirtingus rinkinius pradinių sąlygų su skirtingomis vidutinėmis reakcijos trukmėmis. Tikrojo požymio, kuris tai nulemia nežinome, tačiau žinome, kad atstumas tarp dalelių yra susijęs su reakcijos trukme, todėl galime pabandyti tai naudoti kaip heurisitiką. Specifiškai bandysime klasifikuoti pradinės sąlygas pagal vidutinį mažiausią atstumą iki skirtingos medžiagos dalelės. @n4-mean-distance-examples vaizduoja kaip skaičiuojamas toks vidurkis.

// Examples of the most common mean distances for n = 4, printed by n4_mean_distance.py (the trial
// closest to each group median). Arrangement as in random-ic, and each particle farther than 1 from
// the other material with an arrow to one of its nearest particles of the other material:
// (i, j, nearest i, nearest j, distance), i counts columns from the left and j rows from the bottom
#let mean-distance-ic(arrangement, marks, label) = canvas({
  let rows = arrangement.split(" ")
  let side = 2.8
  let n = rows.len()
  let unit = side / n
  let middle(i, j) = ((i + 0.5) * unit, (j + 0.5) * unit)

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

  for (i, j, ni, nj, d) in marks {
    let (x, y) = middle(i, j)
    let (dx, dy) = (ni - i, nj - j)
    let len = calc.sqrt(dx * dx + dy * dy)
    draw.line((x, y), middle(ni, nj), stroke: 0.75pt, mark: (end: ">", fill: black, scale: 0.5))
    draw.circle((x, y), radius: 0.04, fill: black, stroke: none)
    // The distance on the side of the particle away from the arrow
    draw.content((x - dx / len * 0.24 * unit, y - dy / len * 0.24 * unit), text(size: 8pt, d))
  }

  draw.content((side / 2, 0), anchor: "north", padding: 0.2, align(center, label))
})

#figure(
  grid(
    columns: (1fr,) * 5,
    align: center + top,
    mean-distance-ic("0110 0110 1101 0001", (), [$overline(d) = 1$ \ visos 1 \ $t approx 61$ s]),
    mean-distance-ic("1100 0110 0000 1111", ((3, 0, 2, 1, $sqrt(2)$),), [$overline(d) approx 1.026$ \ $1 times sqrt(2)$ \ $t approx 101$ s]),
    mean-distance-ic(
      "1101 1000 0100 1101",
      ((0, 0, 1, 1, $sqrt(2)$), (2, 1, 1, 0, $sqrt(2)$)),
      [$overline(d) approx 1.052$ \ $2 times sqrt(2)$ \ $t approx 139$ s],
    ),
    mean-distance-ic(
      "0010 1100 0011 0111",
      ((2, 3, 1, 2, $sqrt(2)$), (3, 3, 3, 1, $2$)),
      [$overline(d) approx 1.088$ \ $1 times sqrt(2), 1 times 2$ \ $t approx 169$ s],
    ),
    mean-distance-ic(
      "0001 0010 1011 1110",
      ((0, 0, 0, 2, $2$), (1, 0, 2, 1, $sqrt(2)$), (0, 3, 1, 2, $sqrt(2)$)),
      [$overline(d) approx 1.114$ \ $2 times sqrt(2), 1 times 2$ \ $t approx 176$ s],
    ),
  ),
  caption: [
    Dažniausių vidutinio atstumo $overline(d)$ reikšmių pavyzdžiai, kai $n = 4$. Kiekvienai dalelei imamas atstumas nuo jos centro iki artimiausios kitos medžiagos dalelės centro (dalelės pločiais), $overline(d)$ -- šių atstumų vidurkis per visas daleles. Rodyklės žymi daleles, kurios neturi bendros kraštinės su kitos medžiagos dalele, ir jų artimiausią kitos medžiagos dalelę. Žymėjimas $1 times sqrt(2)$ reiškia, kad viena dalelė yra $sqrt(2)$ atstumu, o visos kitos -- atstumu 1. Po kiekvienu pavyzdžiu nurodyta jo reakcijos trukmė $t$.
  ],
) <n4-mean-distance-examples>

Kiekvieną pradinę konfigūraciją galime priskirti prie grupės, kurios $overline(d)$ reikšmės sutampa. Tokiu būdu galime pamatyti iš ko susideda pasiskirstymas su keliomis viršunėmis.

#figure(
  image("../assets/diagrams/n4-end-time-by-mean-distance.png", width: 85%),
  caption: [
    Reakcijos trukmės pasiskirstymas, kai $n = 4$ (@random-squares-end-time-distribution), išskaidytas pagal penkias dažniausias vidutinio atstumo $overline(d)$ reikšmes (@n4-mean-distance-examples). Skliaustuose nurodytas konfigūracijų skaičius, "kitos" apima likusias 25 reikšmes, o taškuotos linijos žymi pasiskirstymo viršūnes.
  ],
) <n4-end-time-by-mean-distance>

@n4-end-time-by-mean-distance matome, kad prie pirmosios viršūnės (iš kairės) atsiradimo stipriai prisideda konfigūracijos, kurių $overline(d)=1$ ir $overline(d) approx 1.026$. Nėra tokio vienareikšmiškos grupių kombinacijos, kuri lemtų vidurinės viršunės atsiradimą, kaip nutinka pirmuoju atveju. Matome, kad daugiausiai prisideda grupės su $overline(d) approx 1.026, overline(d) approx 1.052$. Trečioji viršūnė atsiranda dėl daugelio grupių, panašią įtaką turi iš grupė, kurios $overline(d) approx 1.052$ ir likusios grupės, kurios nėra detalizuojamos. Taip pat arti šios trukmės yra grupių medianos turinčios mažiau narių ($overline(d) approx 1.088, overline(d) approx 1.114$).

@random-squares-end-time-distribution taip pat matome, kad reakcijos trukmės pasiskirstymai, kurie konstruojami naudojant didesnį $n$ šia savybe beveik nepasižymi (smulkūs artefaktai matomi dešinėse pasiskirstymų uodegose). Tai galėtų lemti faktas, kad pradinių sąlygų variantų skaičius auga eksponentiškai dalelių skaičius atžvilgiu $N = 2^(n ^ 2)$, o su juo ir grupių skaičius, kas reiškia, kad individualiai grupei iškreipti bendrą pasiskirstymą darosi vis sunkiau.

#pagebreak(weak: true)

== Perlino triukšmu grįsta pradinė sąlyga

Ši pradinė salygą pateikiame kaip alternatyvą atsitiktinai išsidėsčiusioms idealioms dalelėms, kuri pasižymi keliomis skirtingomis savybėmis. Šios pradinės sąlygos pagrindas yra Perlino triukšmas -- tolydus pseudoatsitiktinis triukšmas, kuriam sukonstruoti yra apibrėžtas tikslus algoritmas. Ši pradinė sąlyga turi daug daugiau variantų negu prieš tai siūlytas atsitiktinis išsidėstymas su idealiomis dalelėmis, todėl ir reakcijos trukmė gauta naudojant šią pradinę sąlygą yra tolydus pseudoatsitiktinis dydis. 

#figure(
  image("../assets/diagrams/perlin-construction.png", width: 100%),
  caption: [
    Perlino triukšmu grįstos pradinės sąlygos sudarymas, kai $n = 4$. (a) Atsitiktiniai vienetiniai vektoriais gardelės mazguose. (b) Iš jų gautas triukšmas, juoda linija žymi slenkstį, kuris nustatomas pagal $t$ kvantilės parametrą -- $t=0.5$ padalina visas reikšme į dvi grupes (lygias pagal plotą). (c) Gauta pradinė sąlyga: baltos sritys žymi medžiagą $c_1$, pilkos -- $c_2$.
  ],
) <perlin-construction>

@perlin-construction vaizduoja pradinės sąlygos generavimo žingsnius. Pirmasis žingsnis yra paruošti $n times n$ gardelę. Reikėtų atkreipti dėmesį, kad ši gardelė yra daug didesnė nei indvidualių diskrečių taškų gardelė, kuri naudojama modeliuoti molinę medžiagų koncentraciją diskrečiuose erdvės taškuose. Ši gardelė yra naudojama sugeneruoti triukšmo reikšmes. Paskutinis žingsnis yra surasti pasirinktą $t$ kvantilę, pagal kurią tuomet triukšmas gali būti padalintas į dvi nesikertančius plotus, kur $100t$% ploto sudaro pirmoji medžiaga (aliuminio oksidas), o $100(1-t)$% antroji medžiaga (itrio oksidas). Triukšmas naudojamas tik sukonstruoti ploto padalijimą, reagentams naudojamos tos pačios pradinės koncentracijos reikšmės iš @stoichiometric-ratio-derivation[lygties], kurioje buvo išvestas stoichiometrinis medžiagų molių santykis.

#figure(
  image("../assets/diagrams/perlin-cell.png", width: 300pt),
  caption: [
    Įvairių elementų vizualizacija, kurie yra naudojami apskaičiuoti perlino triukšmo reikšmę taške $p=(x,y)$.
  ]
) <perlin-cell>


Vizualizaciją (b) iš @perlin-construction yra sukurta kiekvienam taškui smulkesnėje gardelėje priskyrus triuškmo reikšmę. Triuško reikšmė konkrečiam taškui $p = (x, y)$ yra apskaičiuojama taip kaip pavaizduota @perlin-cell Randame keturis artimiausius kvadrato taškus gardelėje, pavyzdyje jie suindeksuoti $(0, 0), (0, 1), (1, 0), (1, 1)$. Apskaičiuosime poslinkio vektorius $bold(d)_"ij"$ -- kiekvieno iš kvadrato kampų poslinkį iki taško $p$. Žingsnyje (a), @perlin-construction pavaizduoti pseudoatsitiktiniai vektoriai yra pažymėti $bold(v)_"ij"$. Kiekviename gardelės kampe turime du vektorius $bold(v)$ ir $bold(d)$, kurių taškinė sandauga nulemia kampo reikšmę $bold(g)_"ij"$. Triukšmo reikšmė taške $p$ yra gaunama interpoliuojant tarp reikšmių $bold(g)_"ij"$ pirmiausiai $x$ ašimi, o po $y$ naudojant funkciją $S_2(x)$, kitaip žinomą kaip #raw("smootherstep") funkciją.

$
  S_2(x) = cases(
    0 ", kai " x < 0,
    6x^5 - 15x^4+10x^3 ", kai " x in [0, 1], 
    1 ", kai " x > 1
  )
$

Ši funkcija ypatinga tuo, kad $S_2(0) = 0, S_2(1) = 1, S'_2(0) = 0, S'_2(1) = 0$.

#figure(
  image("../assets/diagrams/perlin-parameter-grid.png", width: 70%),
  caption: [
    Perlino triukšmu grįstos pradinės sąlygos priklausomybė nuo gardelės dydžio $n$ ir medžiagos $c_1$ užimamos erdvės dalies $t$. Kiekvienoje eilutėje naudojamas tas pats triukšmas, skiriasi tik slenkstis.
  ],
) <perlin-parameter-grid>

@perlin-parameter-grid pavaizduota kaip šio tipo pradinė sąlyga gali kisti priklausomai nuo gardelės dydžio, nei slenksčio reikšmės pasirinkimo. Eksperimentuose gardelės dydį galime pasirinkti priklausomai nuo to, kokio dydžio sritį norime modeliuoti, tačiau slenkstinę reikšmę galime rinktis bet kokią, todėl reikia nustatyti kaip tą darysime. Nagrinėdame matematinį modelį kartu apibrėžėme stoichiometrinę pradinę sąlygą -- reagentų molių santykis sistemoje turi būti 5:3 norint, kad medžiagos pilnai sureaguotų. Tai galima būtų modeliuoti skirtingais būdais.
Galėtume sukonstruoti tokią pradinę sąlygą, kad skirtingų medžiagų molinė kocentraciją būtų vienoda, tačiau pagal užimama plotą, pirmos medžiagos būtų atitinkamai daugiau, tokiu atveju galėtume pasirinkti slenksčio reikšmę $t = 5 / (3 + 5)$. Alternatyva yra naudoti skirtingas koncentracijų reikšmes suteikiant joms tokį pat plotą, šį metodą taikome modeliuodami kitas pradines sąlygas. Kadangi norime gebėti palyginti sprendinius gautus naudojant skirtingas pradines sąlygas šį metodą taikysime ir su šią pradine sąlyga, taigi naudosime $t = 0.5$.

=== Reakcijos trukmės pasiskirstymas

#figure(
  image("../assets/diagrams/perlin-end-time-distribution.png", width: 85%),
  caption: 
    [Reakcijos trukmės pasiskirstymai, kai naudojama perlino triukšmu grįsta pradinė sąlyga su skirtingo dydžio gardelėmis, $n$ žymi gardelės dydį. Kiekvienam dydžiui įgyvendinta 1000 bandymų.],
) <perlin-end-time-distribution>

@perlin-end-time-distribution matome panašią vizualizaciją, kurią analizavome su atsitiktinio idealių dalelių išdėstymo pradine sąlyga. Pavyzdyje matome įdomu reiškinį -- @random-squares-end-time-distribution matėme, kad didinant dalelių skaičių reakcijos trukmė didėja vis mažesniais tempais artėdama prie nusistovėjusios reikšmės. Šiuo atveju matome priešingą veikimą, reikšmė taip pat nusistovi, tačiau reakcijos trukmė mažėja. 


Taip pat galime pastebėti, kad didinant gardelę, standartinė pasiskirstymo deviacija mažėja. Taip galėtų nutikti dėl to, kad perlino triukšmu grįstoje pradinėje sąlygoje nepalankios reakcijai struktūros turi vis mažesnę galimybę formuotis. Kaip matome @perlin-construction triukšmo reikšmė taškuose, kurie stumpa su gardelės taškais, yra 0. Atidžiai įsižiūrėjus į šitą pavyzdį galime matyti, kad juoda slenksčio linija krinta kaip tik ten kur yra perlino triukšmo reikšmės yra lygiai 0 (balti plotai). Taip yra todėl, kad naudojant kvantilės parametrą $t=0.5$ pradinę sąlygą konstruojantis algoritmas pasirinks tokią slenkstinę reikšmę, kad puse visų reikšmių būtų didesnės už ją. Triukšmo reikšmių intervalas yra simetriškas aplink 0, tai pasirinkta slenkstinė reikšmė bus lygi 0, o tai reiškia, kad slenksčio linija eis per kiekvieną gardelės tašką. Tai paaiškina kodėl
