#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

= Sprendiklio architektūra

== Motyvacija

Skirtingi skaitiniai eksperimentai reikalauja skirtingos informacijos apie sistemos sprendinį. Norint atlikti įvairiapusę vieno atvejo rezultatų analizę gali prireikti išsaugoti visą sprendinį. Norint sukurti koncentracijos pasiskirstymo vizualizaciją gali prireikti vos kelių sprendinio kadrų, kurie taip pat gali būti sumažintos raiškos lyginant su sprendinio rezoliucija, nes rezultatas bus pristatomas kaip paveikslėlis. Norint analizuoti reakcijos pabaigos laiką užtenka išsaugoti paskutinį laiko momentą kada reakciją dar laikėme vykstančią, o duomenų apie sprendinį tokiu atveju išvis neprireikia. Laiko momentais, kai reakcija prasideda yra naudinga naudoti ypač mažą laiko žingsnį norint užfiksuoti svarbias reakcijos mechanikos detales, o kai reakcijos procesą užgožia difuzija norėtume naudoti didelį laiko žingsnį norint nešvaistyti laiko proceso daliai, kuri nėra tokia įdomi iš analitinės pusės. Tyrimui pritaikytas sprendiklis turi atsižvelgti į visus šiuo reikalavimus ir pagaminti tik tokius rezultatus, kurių reikia analizei atlikti. Tai nėra tik principais grįsti reikalavimai -- nagrinėjamos sistemos skaitinis sprendinys gali užimti daugelį gigabaitų atminties, net ir tais atvejais kai naudojama pakankamai paprasto atvejo konfigūracija. Naudojant naivų sprendiklį sunkumai kiltų ne tik dėl atminties trūkumo, bet ir dėl vykdymo laiko, kuris būtų švaistomas kopijuojant atmintį, rašant ją į failą, kai šių rezultatų analizei neprireikia. Dėl šių priežasčių šiame tyrime naudojamo sprendinio archiketūrai aprašyti yra skiriama nemažai dėmesio. 

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
