#import "@preview/fletcher:0.5.8" as fletcher: diagram, edge, node

= Sprendiklio architektūra

== Motyvacija

Skirtingi skaitiniai eksperimentai reikalauja skirtingos informacijos apie sistemos sprendinį. Norint atlikti įvairiapusę vieno atvejo rezultatų analizę, gali prireikti išsaugoti visą sprendinį. Norint sukurti koncentracijos pasiskirstymo vizualizaciją, gali pakakti vos kelių sprendinio kadrų. Jų raiška taip pat gali būti mažesnė nei sprendinio raiška, nes rezultatas bus pateikiamas kaip paveikslėlis. Norint analizuoti reakcijos pabaigos laiką, pakanka išsaugoti paskutinį laiko momentą, kuriuo reakcija dar laikoma vykstančia, o paties sprendinio duomenų tokiu atveju išvis neprireikia.

Laiko momentais, kai reakcija prasideda, naudinga naudoti ypač mažą laiko žingsnį, kad būtų galima užfiksuoti svarbias reakcijos mechanikos detales. Vėliau, kai reakcijos procesą užgožia difuzija, yra naudinga naudoti didesnį laiko žingsnį, kuris paspartina sprendimo laiką.

Tyrimui pritaikytas sprendiklis turi atsižvelgti į visus šiuos reikalavimus ir generuoti tik tuos rezultatus, kurių reikia analizei atlikti. Tai nėra vien principais grįsti reikalavimai -- nagrinėjamos sistemos skaitinis sprendinys gali užimti daugelį gigabaitų atminties net ir tais atvejais, kai naudojama pakankamai paprasto atvejo konfigūracija. Naudojant naivų sprendiklį, sunkumų kiltų ne tik dėl atminties trūkumo, bet ir dėl vykdymo laiko -- renkant duomenis apie sprendinį tenka kopijuoti visas sprendinio reikšmes konkrečiame laiko momente, atlikti dideles atminties alokacijas arba rašyti duomenis į failą.

Dėl šių priežasčių šiame tyrime naudojamo sprendiklio architektūrai aprašyti skiriama nemažai dėmesio.

== Sprendiklio naudojimas

#include "../assets/diagrams/architecture/high-level-arch.typ"

Norint užtikrinti sprendiklio efektyvumą, pagrindinė sprendinį randanti funkcija `solve` ir pagalbinės konfigūracinės konstrukcijos yra patalpintos į vieną modulį `yag_model`, kuris yra įgyvendintas su C++ programavimo kalba. Matricų manipuliacijai naudojama xtensor @xtensor biblioteka, kuri leidžia konstruoti tingiai vykdomas (_angl. lazy_) išraiškas su matricomis. Norint rasti skaitinį sprendinį, reikia spręsti daugelį tridiagonalinių lygčių sistemų (@expanded-tridiagonal-eq[lygt.]) -- efektyvų šių sistemų sprendimo algoritmo įgyvendinimas yra parašytas C++ modulyje; apie programos greitaveiką kalbėsime atskirame skyriuje. Kiekvienai klasei ir funkcijai, kuri turės būti išoriškai naudojama yra apibrėžtą python sąsaja (#box[_angl. binding_]). Rezultatų analizė yra vykdoma WSL (_angl. Windows Subsystem for Linux_) arba VU HPC aplinkoje, todėl sprendiklio sąsajos yra sukompiliuojamos į vieną `.so` failą (_angl. shared object_), kurį tiesiogiai gali importuoti python užrašinės vykdančios rezultatų analizę.

== Sprendiklio sąsaja ir pagrindiniai komponentai


#include "../assets/diagrams/architecture/solver-architecture.typ"

@solver-architecture-diagram yra pavaizduoti pagrindiniai `yag_model` modulio komponentai, kuriais naudojantis galime spręsti YAG sintezės ir panašias sistemas. Pagrindė funkcija, kurią apibrėžia šis modulis yra `solve` -- funkcijos įvestys yra pradinė sąlygą, modelio parametrai, bei sprendėjo konfigūracija, o rezultatas yra abstrakti sąsaja `IResult`, kuri suteikia prieigą prie sprendinio kadrų gabalais (metodas `batch`), tai yra naudinga tokiu atveju, jei sprendinio apimtis yra didelė ir visą sprendinį užkrauti į operatyvią atmintį nėra galima. Kai sprendinys yra nedidelis, jį galima užkrauti visumoje su metodu `all`. Taip pat iš rezultato metaduomenų galime sužinoti apie sprendinio kadrų formą, kokių medžiagų informacija buvo saugoma, kokia tinklelio diskretizacija buvo naudojama ir kokiu veiksmu buvo agreguoti sprendinio duomenys.

=== Diskretizacija

Modelyje naudojame tolygų tinklelį -- horizontalūs ($Delta x$) ir vertikalūs ($Delta y$) atstumai tarp diskrečių tinklelio taškų išlieka pastovūs. Diskrečių taškų kiekis $x$ ir $y$ ašimis yra modeliuojamos erdvės rezoliucija. Diagramoje šis komponentas pažymėtas *`Discretization`*.

=== Laiko žingsnis

@solver-architecture-diagram pavaizduota laiko žingsnio strategija *`ITimeStep`* kontroliuoja kokio dydžio laiko žingsnį naudos sprendiklis ir kaip jis keisis per laiką. Strategijos, kurių laiko žingsnis yra pernelyg didelis yra nepanaudojamos, dėl to, kad sprendinys taps nestabilus ir diverguos, o strategijos, kurios laikosi per mažo laiko žingsnio gali užtrukti nereikalingai ilgai.

=== Reakcijos stabdis

@simplified-chemical-reaction pavaizduota reakcijos stabdžio sąsaja *`IBrake`* kontroliuoja kada modelis laikys reakciją pasibaigusią.
Modeliuojame reakcijos-difuzijos sistemą, kurioje reagentų reakcijos greitis yra proporcingas kiekiui, dėl šios priežasties nėra laiko momento, kada bus sureagavę visi reagentai -- su šia problema susiduria ir chemikai. Praktikoje turime pasirinkti tokią stabdymo sąlygą, kuri leistų suvaldyti sprendinio paieškos laiką. Turime keletą dažnai naudojamų strategijų:

- Nurodyto laiko stabdis -- pavyzdžiui, reakciją stabdome po 4 simuliacijos valandų
- Žingsnių skaičiaus stabdis -- reakciją stabdome tuomet, kai modelis įvykdo nurodytą diskrečių laiko žingsnių kiekį. Šis metodas skiriasi nuo nurodyto laiko stabdžio, nes laiko žingsnio dydis gali kisti.
- Reagentų masės dalies stabdis -- reakcija stabdoma tuomet, kai bendra reagentų masė pasiekia nedidelį, iš anksto nustatytą, bendros visų reakcijos medžiagų masės procentą.

=== Stoichiometrinė matrica

Stoichiometrinė matricą lemia modeliuojama cheminė reakcija, dažniausiai tai bus ta pati matrica $bold(S)$, kurią jau matėme anksčiau @compact-model-and-related-notation[ lygtyje], nes pagrindinė nagrinėjama sistema yra YAG sintezė.

=== Fiksavimo konfigūracija

@solver-architecture-diagram pavaizduota sprendėjo fiksavimo konfigūracija *`CaptureConfig`* kontroliuoja kaip, kada ir kur bus saugomi sprendinio kadrai. Pavyzdžiui,

- Laukelis `channels` yra bitų vėliavėlė (_angl. bitflag_), kuri leidžia pasirinkti kurių medžiagų kadrus norėsime saugoti.
- *`IReducer`* yra kadrų agregavimo sąsaja. Šis komponentas gali transformuoti kadro duomenis prieš juos išsaugant. @reducer-diagram yra pavaizduotos keturios realizacijos iš @solver-architecture-diagram ir ryšys tarp jų.
- *`ISink`* yra saugojimo vietos sąsaja, ji kontroliuoja kur bus išsaugoti transformuoti sprendinio duomenys. Šiame darbe naudojamos dvi realizacijos -- realizacija, kuri išsaugo duomenis atmintyje (*`InMemorySink`*) ir realizacija, kuri išsaugo duomenis HDF5 formato faile (*`HDF5Sink`*). HDF5 yra plačiai naudojamas failo formatas saugoti įvairaus pobūdžio skaitinius duomenis ir jų metaduomenis.
- *`ITrigger`* yra saugojimo momento sąsaja, šios sąsajos realizacijos kontroliuoja kada sprendinio kadras bus saugojamas. Paprasčiausia šios sąsajos realizacija išsaugo kiekvieną kadrą, tačiau kai diskrečių laiko žingsnių vykdoma labai daug, saugoti kiekvieną kadrą gali būti per brangu, tokiu atveju naudojamos strategijos, kurios kiekviena kartą praleidžia $n$ kadrų (*`StrideTrigger`*), arba fiksuoja tik paskutinį reakcijos kadrą (*`LastFrameTrigger`*).

#include "../assets/diagrams/architecture/reducers.typ"

// Laukelis `reducer` apibudina kaip bus agreguojami kadro duomenys prieš juos išsaugant. Pavyzdžiui, kai nagrinėjame

// Modulis `yag_model` įgyvendina funkciją `solve`, kuri skaitiškai sprendžia sistemą apibūdintą @mathematical-model[skyriuje]. Ši funkcija turi keletą parametrų:
// - $bold(S) in RR^(5 times 3)$ -- stoichiometrinė sistemos matrica. Atliekant įprastą rezultatų analizę šio parametro reikšmė bus tokia pati kaip @compact-model-and-related-notation[lygt.] esančios matricos $bold(S)$. Ši matrica egzistuoja kaip funkcijos parametras dėl to, kad būtų įmanoma testuoti modelio veikimą nepriklausomai nuo duotos stoichiometrinės matricos. Anksčiau minėtą supaprastiną cheminę reakciją @vaicekauskas2025yag galime modeliuoti paprasčiausiai pakeičiant šio argumento reikšmę.
// - `Discretization` -- erdvės diskretizacijos konfigūracija kontroliuoja modeliuojamos erdvės granuliarumą ir fizinį dydį, detaliau pavaizduota @solver-inputs-diagram
// - `ModelParameters` -- struktūra laikanti modelio fizines konstantas -- difuzijos ir reakcijos greičius. Detaliau pavaizduota @solver-inputs-diagram
// - `ITimeStep` -- žingsniavimo strategija, plačiau aprašyta @time-step-section[skyriuje]
// - `IBrake` -- reakcijos stabdymo strategija, plačiau aprašyta @brake-component-section[skyriuje]
// - `ICaptureTrigger` -- sprendinio fiksavimo dažnio strategija, plačiau aprašyta @capture-component-section[skyriuje]
// - `ICapture` -- sprendinio formos fiksavimo strategija, plačiau aprašyta @capture-component-section[skyriuje]
// - `SolutionState` -- pradinė sąlyga, detaliau pavaizduota @solver-inputs-diagram

// #include "../assets/diagrams/architecture/solver-inputs.typ"

// === Laiko žingsnio strategijos <time-step-section>

// #include "../assets/diagrams/architecture/timestep-component.typ"

// @timestep-component-diagram pavaizduotas laiko žingsnio strategijos sąsaja. Jis leidžia kontroliuoti kaip reakcijos eigoje keičiasi laiko žingsnis. Metodas `getTimestep` suteikia prieigą prie dabartinio laiko žingsnio, o metodas `advance` atnaujina laiko žingsnį. Praktikoje norėtume naudoti strategiją, kuri suteikia kuo didesnį laiko žingsnį, tačiau tuo pačiu metu išlaiko modelį skaitiškai stabiliu, šiam balansui nustatyti gali prireikti informacijos apie sistemos sprendinį todėl kaip argumentą paduodame sprendiklio būseną. @timestep-component-diagram taip pat nurodytos galimos sąsajos realizacijos:
// - Fiksuotas laiko žingsnis (`FixedTimeStep`) -- žingsnio dydis išlieka pastovus
// - Geometrinis laiko žingsnis (`GeometricTimeStep`) -- žingsnio dydis didėja sekdamas geometrinę progresiją $Delta t_n = Delta t_0 r^n$

// Praktikoje naudojame subtilesnes laiko žingsnio strategijas, kurios bus aptartos ateinančiuose skyriuose.

// === Reakcijos stabdymo strategijos <brake-component-section>

// #include "../assets/diagrams/architecture/brake-component.typ"

// @brake-component-diagram pavaizduota reakcijos stabdymo strategijos sąsaja ir naudojamos realizacijos, kurios tikslas yra nustatyti ar reakcijos stabdymo sąlyga yra išpildyta, kurio atveju sprendiklis nutraukia sprendimo ciklą. Tiksli stabdymo sąlyga priklauso nuo naudojamos realizacijos -- pačios paprasčiausios stabdymo strategijos yra fiksuoto laiko (`FixedTimeBrake`) arba fiksuoto laiko žingsnio (`FixedStepBrake`) realizacijos, kurios yra naudingos norint nustatyti ar sprendinys tenkina tam tikrą požymi, pavyzdžiui, nekintančią masę (@const-mass).

// Praktikoje YAG sintezės reakcija yra vykdoma tol kol sureaguoja tam tikras procentas procentas pradinių medžiagų masės -- pilnai reagentai nesureaguoja todėl, kad produktas gaminasi greičiu proporcingu reagentų kiekiui, o reakcija teoriškai niekad nesibaigia, tik nuolat lėtėja. Tokį reakcijos stabdymą galime modeliuoti su realizacija `ProductThresholdBrake`. Čia `threshold` -- iš anksto nustatytas produkto masės procentas, kurį pasiekus stabdymo sąlyga bus tenkinama, o `initial_mass` --  pradinė reagentų masė. Kadangi metodas `shouldBrake` kaip įvestį gauną dabartinę sprendiklio būseną `s`, visą informacija, kurios reikia nustatyti dabartinę produkto masę yra turima.

// === Sprendinio fiksavimo strategijos <capture-component-section>

// #include "../assets/diagrams/architecture/capture-components.typ"

// @capture-component-diagram pavaizduotos strategijų sąsajos yra naudojamos kontroliuoti kaip dažnai ir kokie duomenys yra renkami apie sprendinį. Sąsaja `ICaptureTrigger` kontroliuoja kada informacija apie sprendinį bus surinkta, pora naudingų realizacijų:

// - Realizacija `StrideCaptureTrigger` surenka duomenis apie sprendinį kas $n$ (`stride`) žingsnių
// - Realizacija `LastFrameCaptureTrigger` surenka duomenis apie sprendinį tik tą žingsnį, ties kuriuo reakcijos stabdymo komponentas `IBrake` nusprendžia, kad reakcija yra pasibaigusi, dėl to @capture-component-diagram galime matyti šios realizacijos priklausomybę nuo minėto komponento `IBrake`

// Sąsaja `ICapture` kontroliuoja kokie duomenys apie sprendinį yra renkami ir kur jie saugomi. Atliekant rezultatų analizę dažniausiai pasirenkame konfigūraciją, kuri duomenis išsaugo atmintyje, o keičiame tik saugomų duomenų formą.

// - `InMemoryFrameCapture` -- ši realizacija užfiksuoja pilną sprendinį laiko momentu $t_n$, kurio forma yra $bold(c)(t=t_n) in RR^(5 times W times H)$
// - `InMemoryQuantityCapture` -- užfiksuoja medžiagos kiekį laiko momentu $t_n$, #box[$bold(q)(t = t_n) in RR^5$]

// == Sprendimo ciklas

// #include "../assets/diagrams/architecture/solver-loop.typ"

== Sprendiklio efektyvumas

- Ką rašysiu?
- Tridiagonalinis sprendimas
  - in place
  - stabilumas

