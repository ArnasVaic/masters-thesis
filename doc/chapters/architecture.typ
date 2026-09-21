#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

= Sprendiklio architektūra

== Motyvacija

Skirtingi skaitiniai eksperimentai reikalauja skirtingos informacijos apie sistemos sprendinį. Norint atlikti įvairiapusę vieno atvejo rezultatų analizę, gali prireikti išsaugoti visą sprendinį. Norint sukurti koncentracijos pasiskirstymo vizualizaciją, gali pakakti vos kelių sprendinio kadrų. Jų raiška taip pat gali būti mažesnė nei sprendinio raiška, nes rezultatas bus pateikiamas kaip paveikslėlis. Norint analizuoti reakcijos pabaigos laiką, pakanka išsaugoti paskutinį laiko momentą, kuriuo reakcija dar laikoma vykstančia, o paties sprendinio duomenų tokiu atveju išvis neprireikia.

Laiko momentais, kai reakcija prasideda, naudinga naudoti ypač mažą laiko žingsnį, kad būtų galima užfiksuoti svarbias reakcijos mechanikos detales. Vėliau, kai reakcijos procesą užgožia difuzija, norėtume naudoti didesnį laiko žingsnį, kad laikas nebūtų švaistomas proceso daliai, kuri analitiniu požiūriu nėra tokia svarbi.

Tyrimui pritaikytas sprendiklis turi atsižvelgti į visus šiuos reikalavimus ir generuoti tik tuos rezultatus, kurių reikia analizei atlikti. Tai nėra vien principais grįsti reikalavimai -- nagrinėjamos sistemos skaitinis sprendinys gali užimti daugelį gigabaitų atminties net ir tais atvejais, kai naudojama pakankamai paprasto atvejo konfigūracija. Naudojant naivų sprendiklį, sunkumų kiltų ne tik dėl atminties trūkumo, bet ir dėl vykdymo laiko, kuris būtų švaistomas kopijuojant atmintyje esančius duomenis ir rašant juos į failą, kai šių rezultatų analizei neprireikia.

Dėl šių priežasčių šiame tyrime naudojamo sprendiklio architektūrai aprašyti skiriama nemažai dėmesio.

#pagebreak()

== Aukšto lygio architektūra

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
  caption: [Aukšto lygio skaičiavimų vykdymo diagrama,.]
)

Norint užtikrinti sprendiklio efektyvumą, pagrindinė sprendinį randanti funkcija `solve` ir pagalbinės konfigūracinės konstrukcijos yra patalpintos į vieną modulį `yag_model`, kuris yra įgyvendintas su C++ programavimo kalba. Matricų manipuliacijai naudojama xtensor @xtensor biblioteka, kuri leidžia konstruoti tingiai vykdomas (_angl. lazy_) išraiškas su matricomis. Norint rasti skaitinį sprendinį, reikia spręsti daugelį tridiagonalinių lygčių sistemų (@expanded-tridiagonal-eq[lygt.]) -- efektyvų šių sistemų sprendimo algortimo įgyvendinimą suteikia tiesinės algebros algoritmų biblioteka LAPACK @lapack. Kiekvienai klasei ir funkcijai, kuri turės būti išoriškai naudojama yra apibrėžtą python sąsaja (#box[_angl. binding_]). Rezultatų analizė yra vykdoma WSL (_angl. Windows Subsystem for Linux_) arba VU HPC aplinkoje, todėl sprendiklio sąsajos yra sukompiliuojamos į vieną `.so` failą (_angl. shared object_), kurį tiesiogiai gali importuoti python užrašinės vykdančios rezultatų analizę.

== Sprendiklio architektūra



#set par(first-line-indent: 0pt)

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
    // debug: true,
    node-fill: rgb("#d5d5d6"),
    node-corner-radius: 3pt,
    node-stroke: 1pt,
    node-inset: 8pt,
    node((0, 0), name: <qnt-title>,
    stroke: none, fill: none, [
      Kiekybiniai komponentai
    ]),
    node((0, 0.75), name: <solver-state>, [
      *`SolverState`* \
      #align(left, [
        #raw("time: double") \
        #raw("solution: SolutionState") \
        #raw("step: size_t")
      ])
    ]),
    node((0, 1.75), name: <time-step>, [
      *`ITimeStep`*
      #align(left, [
        #raw("getTimestep(): double") \
        #raw("advance(s: SolverState)")
      ])
    ]),
    node((0, 2.75), name: <brake>, [
      *`IBrake`*
      #align(left, [
        #raw("shouldBrake(s: SolverState): bool")
      ])
    ]),
    node((0, 3.75), name: <capture-trigger>, [
      *`ICaptureTrigger`*
      #align(left, [
        #raw("shouldCapture(s: SolverState): bool")
      ])
    ]),
    node((0, 4.75), name: <capture>, [
      *`ICapture`*
      #align(left, [
        #raw("capture(s: SolverState): bool")
      ])
    ]),
    node(
      stroke: (dash: "dashed"),
      fill: white, 
      enclose: (
        <solver-state>,
        <time-step>,
        <qnt-title>,
        <capture-trigger>,
        <capture>),
      name: <qnt-group>
    ),
    node((1, 2.5), name: <solve>, [
      *`solve()`*
    ]),
    edge(<qnt-group>, <solve>, "-|>"),
    node((2, 0), name: <ic>, [
      *`InitialCondition`*
    ]),
    node((2, 0.75), name: <ic>, [
      *`Discretization`*
      #align(left, [
        #raw("mesh_resolution_x: size_t") \
        #raw("mesh_resolution_y: size_t") \
        #raw("physical_width: double") \
        #raw("physical_height: double")
      ])
    ]),
    node((2, 1.75), name: <ic>, [
      *`ModeParameters`*
      #align(left, [
        #raw("D: double[5]") \
        #raw("k: double[3]")
      ])
    ]),
  ),
  caption: [Sprendklio konstrukcijai reikalingi komponentai.]
) <solver-components>

@solver-components yra pavaizduota kažkas?


#figure(
  diagram(
    node-stroke: 1pt,
    node-fill: rgb("eeeeee"),
    node-corner-radius: 3pt,
    node-inset: 5pt,
    spacing: (7mm, 10mm),

    node((1,0), comp("solve()", note: []), name: <solve>),

    node((0,1.4), comp("SolverState", fields: ("solution : SolutionState", "time : double", "step : size_t")), name: <state>),
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
