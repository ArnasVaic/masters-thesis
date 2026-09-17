#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

= Sprendiklio architektūra

== Motyvacija

Skirtingi skaitiniai eksperimentai reikalauja skirtingos informacijos apie sistemos sprendinį. Norint atlikti įvairiapusę vieno atvejo rezultatų analizę, gali prireikti išsaugoti visą sprendinį. Norint sukurti koncentracijos pasiskirstymo vizualizaciją, gali pakakti vos kelių sprendinio kadrų. Jų raiška taip pat gali būti mažesnė nei sprendinio raiška, nes rezultatas bus pateikiamas kaip paveikslėlis. Norint analizuoti reakcijos pabaigos laiką, pakanka išsaugoti paskutinį laiko momentą, kuriuo reakcija dar laikoma vykstančia, o paties sprendinio duomenų tokiu atveju išvis neprireikia.

Laiko momentais, kai reakcija prasideda, naudinga naudoti ypač mažą laiko žingsnį, kad būtų galima užfiksuoti svarbias reakcijos mechanikos detales. Vėliau, kai reakcijos procesą užgožia difuzija, norėtume naudoti didesnį laiko žingsnį, kad laikas nebūtų švaistomas proceso daliai, kuri analitiniu požiūriu nėra tokia svarbi.

Tyrimui pritaikytas sprendiklis turi atsižvelgti į visus šiuos reikalavimus ir generuoti tik tuos rezultatus, kurių reikia analizei atlikti. Tai nėra vien principais grįsti reikalavimai -- nagrinėjamos sistemos skaitinis sprendinys gali užimti daugelį gigabaitų atminties net ir tais atvejais, kai naudojama pakankamai paprasto atvejo konfigūracija. Naudojant naivų sprendiklį, sunkumų kiltų ne tik dėl atminties trūkumo, bet ir dėl vykdymo laiko, kuris būtų švaistomas kopijuojant atmintyje esančius duomenis ir rašant juos į failą, kai šių rezultatų analizei neprireikia.

Dėl šių priežasčių šiame tyrime naudojamo sprendiklio architektūrai aprašyti skiriama nemažai dėmesio.

== Aukšto lygio archiketūra

#figure(
  diagram(
    node-fill: rgb("#d5d5d6"),
    node-corner-radius: 3pt,
    node-stroke: 1pt,
    node-inset: 10pt,
    node((0,0), [
      *yag_model*
      #linebreak()
      (įgyvendinta C++)
    ], name: <solver>),
    node((1,-0.75), [
      *yag_model.so*
      #linebreak()
      (shared object)
    ], name: <shared-obj>),
    node((2,0), [
      *python užrašinės*
      #linebreak()
      (rezultatų analizė)
    ], name: <python>),
    edge(<solver>, <shared-obj>, "-|>", label: "kompiliuojasi į"),
    edge(<python>, <shared-obj>, "-|>", label: "naudoja")
  ),
  caption: [Aukšto lygio skaičiavimų vykdymo diagrama]
)

Norint užtikrinti sprendiklio efektyvumą, pagrindinė sprendinį randanti funkcija `solve` ir pagalbinės konfigūracinės konstrukcijos yra įgyvendintos su C++ programavimo kalba. Efektyviai matricų manipuliacijai naudojama xtensor @xtensor biblioteka, kuri leidžia konstruoti tingiai vykdomas (_angl. lazy_) išraiškas su matricomis. Norint rasti skaitinį sprendinį, reikia spręsti daugelį tridiagonalinių lygčių sistemų (@expanded-tridiagonal-eq[lygt.]) -- efektyvų šių sistemų sprendimo algortimo įgyvendinimą suteikia tiesinės algebros algoritmų biblioteka LAPACK @lapack. Kiekvienai klasei ir funkcijai, kuri turės būti išoriškai naudojama yra apibrėžtą python sąsaja (#box[_angl. binding_]). Kadangi tyrimas vykdomas WSL (_angl. Windows Subsystem for Linux_) aplinkoje, sprendiklio sąsajos yra sukompiliuojamos į vieną `.so` failą (_angl. shared object_), kurį tiesiogiai gali importuoti python užrašinės, kuriose vykdoma tyrimo rezultatų analizė.

== Sprendiklio architektūra

#let comp(title, fields: (), note: none) = align(left)[
  #strong(raw(title))
  #if fields.len() > 0 [
    // #v(1pt)
    #line(length: 100%, stroke: 0.4pt + gray)
    // #v(1pt)
    #text(size: 9pt)[
      #for f in fields [
        #raw(f) \
      ]
    ]
  ] else if note != none [
    #v(3pt)
    #text(size: 9pt)[#note]
  ]
]

#figure(
  diagram(
    node-stroke: 1pt,
    node-fill: rgb("eeeeee"),
    node-corner-radius: 3pt,
    node-inset: 5pt,
    spacing: (7mm, 10mm),

    node((1,0), comp("solve()", note: []), name: <solve>, width: 32mm),

    node((0,1.4), comp("SolverState", fields: ("solution : SolutionState", "time : double", "step : size_t")), name: <state>, width: 38mm),
    node((1,1.4), comp("ITimeStep", fields: ("getTimestep() : double", "advance(state)")), name: <timestep>, width: 38mm),
    node((2,1.4), comp("IBrake", fields: ("shouldBrake(state) : bool",)), name: <brake>, width: 38mm),

    node((0.5,2.8), comp("ICaptureTrigger", fields: ("shouldCapture(state) : bool",)), name: <trigger>, width: 38mm),
    node((1.5,2.8), comp("ICapture", fields: ("capture(state)",)), name: <capture>, width: 38mm),

    edge(<solve>, <state>, "-|>"),
    edge(<solve>, <timestep>, "-|>"),
    edge(<solve>, <brake>, "-|>"),
    edge(<solve>, <trigger>, "-|>"),
    edge(<solve>, <capture>, "-|>"),
  ),
  caption: [Sprendiklio komponentai. `solve()` naudoja būsenos objektą `SolverState` bei keturias strategijos sąsajas; kiekvieno bloko viduje nurodyti jo metodai (ar laukai), atskleidžiantys komponento atsakomybę.]
	) <fig-architecture>
