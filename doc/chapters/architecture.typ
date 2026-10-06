#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

= Sprendiklio architektūra

== Motyvacija

Skirtingi skaitiniai eksperimentai reikalauja skirtingos informacijos apie sistemos sprendinį. Norint atlikti įvairiapusę vieno atvejo rezultatų analizę, gali prireikti išsaugoti visą sprendinį. Norint sukurti koncentracijos pasiskirstymo vizualizaciją, gali pakakti vos kelių sprendinio kadrų. Jų raiška taip pat gali būti mažesnė nei sprendinio raiška, nes rezultatas bus pateikiamas kaip paveikslėlis. Norint analizuoti reakcijos pabaigos laiką, pakanka išsaugoti paskutinį laiko momentą, kuriuo reakcija dar laikoma vykstančia, o paties sprendinio duomenų tokiu atveju išvis neprireikia.

Laiko momentais, kai reakcija prasideda, naudinga naudoti ypač mažą laiko žingsnį, kad būtų galima užfiksuoti svarbias reakcijos mechanikos detales. Vėliau, kai reakcijos procesą užgožia difuzija, norėtume naudoti didesnį laiko žingsnį, kad laikas nebūtų švaistomas proceso daliai, kuri analitiniu požiūriu nėra tokia svarbi.

Tyrimui pritaikytas sprendiklis turi atsižvelgti į visus šiuos reikalavimus ir generuoti tik tuos rezultatus, kurių reikia analizei atlikti. Tai nėra vien principais grįsti reikalavimai -- nagrinėjamos sistemos skaitinis sprendinys gali užimti daugelį gigabaitų atminties net ir tais atvejais, kai naudojama pakankamai paprasto atvejo konfigūracija. Naudojant naivų sprendiklį, sunkumų kiltų ne tik dėl atminties trūkumo, bet ir dėl vykdymo laiko, kuris būtų švaistomas kopijuojant atmintyje esančius duomenis ir rašant juos į failą, kai šių rezultatų analizei neprireikia.

Dėl šių priežasčių šiame tyrime naudojamo sprendiklio architektūrai aprašyti skiriama nemažai dėmesio.

== Sprendiklio naudojimas

#include "../assets/diagrams/architecture/high-level-arch.typ"

Norint užtikrinti sprendiklio efektyvumą, pagrindinė sprendinį randanti funkcija `solve` ir pagalbinės konfigūracinės konstrukcijos yra patalpintos į vieną modulį `yag_model`, kuris yra įgyvendintas su C++ programavimo kalba. Matricų manipuliacijai naudojama xtensor @xtensor biblioteka, kuri leidžia konstruoti tingiai vykdomas (_angl. lazy_) išraiškas su matricomis. Norint rasti skaitinį sprendinį, reikia spręsti daugelį tridiagonalinių lygčių sistemų (@expanded-tridiagonal-eq[lygt.]) -- efektyvų šių sistemų sprendimo algoritmo įgyvendinimą suteikia tiesinės algebros algoritmų biblioteka LAPACK @lapack. Kiekvienai klasei ir funkcijai, kuri turės būti išoriškai naudojama yra apibrėžtą python sąsaja (#box[_angl. binding_]). Rezultatų analizė yra vykdoma WSL (_angl. Windows Subsystem for Linux_) arba VU HPC aplinkoje, todėl sprendiklio sąsajos yra sukompiliuojamos į vieną `.so` failą (_angl. shared object_), kurį tiesiogiai gali importuoti python užrašinės vykdančios rezultatų analizę.

== Sprendiklio sąsaja ir pagrindiniai komponentai

Modulis `yag_model` įgyvendina funkciją `solve`, kuri skaitiškai sprendžia sistemą apibūdintą @mathematical-model[skyriuje]. Ši funkcija turi keletą parametrų:
- $bold(S) in RR^(5 times 3)$ -- stoichiometrinė sistemos matrica. Atliekant įprastą rezultatų analizę šio parametro reikšmė bus tokia pati kaip @model-constants[lygt.]. Ši matrica egzistuoja kaip funkcijos parametras dėl to, kad būtų įmanoma testuoti modelio veikimą nepriklausomai nuo duotos stoichiometrinės matricos. Anksčiau minėtą supaprastiną cheminę reakciją @vaicekauskas2025yag galime modeliuoti paprasčiausiai pakeičiant šio argumento reikšmę.
- `Discretization` -- erdvės diskretizacijos konfigūracija kontroliuoja modeliuojamos erdvės granuliarumą ir fizinį dydį, detaliau pavaizduota @solver-inputs-diagram
- `ModelParameters` -- struktūra laikanti modelio fizines konstantas -- difuzijos ir reakcijos greičius. Detaliau pavaizduota @solver-inputs-diagram
- `ITimeStep` -- žingsniavimo strategija, plačiau aprašyta @time-step-section[skyriuje]
- `IBrake` -- reakcijos stabdymo strategija, plačiau aprašyta @brake-component-section[skyriuje]
- `ICaptureTrigger` -- sprendinio fiksavimo dažnio strategija, plačiau aprašyta @capture-component-section[skyriuje]
- `ICapture` -- sprendinio formos fiksavimo strategija, plačiau aprašyta @capture-component-section[skyriuje]
- `SolutionState` -- pradinė sąlyga, detaliau pavaizduota @solver-inputs-diagram

#include "../assets/diagrams/architecture/solver-inputs.typ"

=== Laiko žingsnio strategijos <time-step-section>

#include "../assets/diagrams/architecture/timestep-component.typ"

@timestep-component-diagram pavaizduotas laiko žingsnio strategijos sąsaja. Jis leidžia kontroliuoti kaip reakcijos eigoje keičiasi laiko žingsnis. Metodas `getTimestep` suteikia prieigą prie dabartinio laiko žingsnio, o metodas `advance` atnaujina laiko žingsnį. Praktikoje norėtume naudoti strategiją, kuri suteikia kuo didesnį laiko žingsnį, tačiau tuo pačiu metu išlaiko modelį skaitiškai stabiliu, šiam balansui nustatyti gali prireikti informacijos apie sistemos sprendinį todėl kaip argumentą paduodame sprendiklio būseną. @timestep-component-diagram taip pat nurodytos galimos sąsajos realizacijos: 
- Fiksuotas laiko žingsnis (`FixedTimeStep`) -- žingsnio dydis išlieka pastovus
- Geometrinis laiko žingsnis (`GeometricTimeStep`) -- žingsnio dydis didėja sekdamas geometrinę progresiją $Delta t_n = Delta t_0 r^n$

Praktikoje naudojame subtilesnes laiko žingsnio strategijas, kurios bus aptartos ateinančiuose skyriuose.

=== Reakcijos stabdymo strategijos <brake-component-section>

#include "../assets/diagrams/architecture/brake-component.typ"

@brake-component-diagram pavaizduota reakcijos stabdymo strategijos sąsaja ir naudojamos realizacijos, kurios tikslas yra nustatyti ar reakcijos stabdymo sąlyga yra išpildyta, kurio atveju sprendiklis nutraukia sprendimo ciklą. Tiksli stabdymo sąlyga priklauso nuo naudojamos realizacijos -- pačios paprasčiausios stabdymo strategijos yra fiksuoto laiko (`FixedTimeBrake`) arba fiksuoto laiko žingsnio (`FixedStepBrake`) realizacijos, kurios yra naudingos norint nustatyti ar sprendinys tenkina tam tikrą požymi, pavyzdžiui, nekintančią masę (@const-mass). 

Praktikoje YAG sintezės reakcija yra vykdoma tol kol sureaguoja tam tikras procentas procentas pradinių medžiagų masės -- pilnai reagentai nesureaguoja todėl, kad produktas gaminasi greičiu proporcingu reagentų kiekiui, o reakcija teoriškai niekad nesibaigia, tik nuolat lėtėja. Tokį reakcijos stabdymą galime modeliuoti su realizacija `ProductThresholdBrake`. Čia `threshold` -- iš anksto nustatytas produkto masės procentas, kurį pasiekus stabdymo sąlyga bus tenkinama, o `initial_mass` --  pradinė reagentų masė. Kadangi metodas `shouldBrake` kaip įvestį gauną dabartinę sprendiklio būseną `s`, visą informacija, kurios reikia nustatyti dabartinę produkto masę yra turima. 

=== Sprendinio fiksavimo strategijos <capture-component-section>

#include "../assets/diagrams/architecture/capture-components.typ"

@capture-component-diagram pavaizduotos strategijų sąsajos yra naudojamos kontroliuoti kaip dažnai ir kokie duomenys yra renkami apie sprendinį. Sąsaja `ICaptureTrigger` kontroliuoja kada informacija apie sprendinį bus surinkta, pora naudingų realizacijų:

- Realizacija `StrideCaptureTrigger` surenka duomenis apie sprendinį kas $n$ (`stride`) žingsnių
- Realizacija `LastFrameCaptureTrigger` surenka duomenis apie sprendinį tik tą žingsnį, ties kuriuo reakcijos stabdymo komponentas `IBrake` nusprendžia, kad reakcija yra pasibaigusi, dėl to @capture-component-diagram galime matyti šios realizacijos priklausomybę nuo minėto komponento `IBrake`

Sąsaja `ICapture` kontroliuoja kokie duomenys apie sprendinį yra renkami ir kur jie saugomi. Atliekant rezultatų analizę dažniausiai pasirenkame konfigūraciją, kuri duomenis išsaugo atmintyje, o keičiame tik saugomų duomenų formą.

- `InMemoryFrameCapture` -- ši realizacija užfiksuoja pilną sprendinį laiko momentu $t_n$, kurio forma yra $bold(c)(t=t_n) in RR^(5 times W times H)$
- `InMemoryQuantityCapture` -- užfiksuoja medžiagos kiekį laiko momentu $t_n$, #box[$bold(q)(t = t_n) in RR^5$]

== Sprendimo ciklas

#include "../assets/diagrams/architecture/solver-loop.typ"

== Sprendiklio efektyvumas



