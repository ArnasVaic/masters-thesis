= Skaitinio modelio rezultatai

#let reaction_const_unit = $$

#figure(
  image("../assets/diagrams/const-mass.png"),
  caption: [Skaitinio modelio rezultatai. Medžiagų masių procentinių dalių evoliucija laike. Naudota diskrečios erdvės rezoliucija $40 times 40$, $Delta x = Delta y approx 2.5 times 10^(-2) mu m$, laiko žingsnis -- pastovus $Delta t = 10^(-4)s$, o visas reakcijos laikas $T=10s$. Modelio parametrai $D_i = 10^(-2) mu m^2\/s$, $k_1=10.0, k_2=5.0, k_3=1.0, "kur" [k_i] = mu m^3\/("mol" dot s)$. ],
) <const-mass>

#let it-ox = $"Y"_2"O"_3$
#let al-ox = $"Al"_2"O"_3$
#let yap = $"YAlO"_3$
#let yam = $"Y"_4"Al"_2"O"_9$
#let yag = $"Y"_3"Al"_5"O"_12$

@const-mass pavaizduoti skaitinio modelio rezultatai, matome kaip laikui bėgant sistemoje keičiasi skirtingų medžiagų procentinės masės dalys. Reakcijos pradžioje 100% masės sudaro reagentai #al-ox ir #it-ox, tačiau laikui bėgant šios medžiagos reaguoja ir sudaro tarpinius junginius YAM ir YAP bei produktą YAG. Reakcijos metu naujų reagentų į sistemą nepridedama, todėl jų kiekis sistemoje nedidėja. YAP ir YAM junginiai reakcijoje yra pagaminami, tačiau ir suvartojami, todėl jų kiekis sistemoje reakcijos pradžioje išauga, o po to, lėtai nyksta.

Vienas iš svarbiausių @const-mass matomų rezultatų yra žalsva linija $Sigma$, kuri žymi visų medžiagų masės sumos santykį su pradine reagentų sumą:
// integral_Omega c_i (x,y,t)d V
$
  Sigma(t_n) = 1/m_0 sum_(i=1)^5 q_i (t_n) M_i
$

Čia $q_i$ yra medžiagų molinis kiekis diskrečiu laiko momentu $t_n$, $M_i$ yra medžiagos molinės masės, o $m_0$ pradinių medžiagų masė prieš reakciją. Svarbu atkreipti dėmesį į tai, kad šis dydis laikui bėgant išlieka toks pat, tai reiškia, kad sprendžiant sistemą skaitiniais metodais, per $10^5$ diskrečių laiko žingsnių neatsirado skaičiavimo paklaidų, dėl kurių bendra sistemos masė galėtų pakisti.

#pagebreak(weak: true)

// Kokio pavyzdžio noriu?
// Gal kažkaip galime integruoti pavyzdį su paprastesnę stoichiometrine matrica, tokiu būdu galėtume pademonstruoti
// gauto sprendinio simetrija x/y ašių atžvilgiu, o parodžius sudetingesnės sistemos kiltų klausimas, kodėl?
// Iš vienos pusės klausimas kylą ir taip (kursinio recenzija), tačiau iš kitos, man reikia puslapių:)
// Kaip dar pagrįsti paprastenės stoichiometinės matricos pavyzdį? Lyginam su savo bakalauro rezultatais?

== Supaprastinto modelio rezultatų verifikavimas

Vienas iš šio modelio architektūros privalumų -- vartotojas dirbantis su sprendėjo API turi galimybę savo nuožiūra pasirinkti stoichiometrinę matricą, kuri bus naudojama rasti sprendinį. Tai leidžia modeliuoti ne tik papildytą YAG sintezės uždavinį, kurį nagrinėjame šiame tyrime, tačiau ir panašias sistemas, pavyzdžiui, anksčiau minėtą supaprastintą YAG sintezės modelį (@simplified-chemical-reaction[lygt.]), kurio stoichiometrinė matrica atrodytų taip:

$
  bold(S) = mat(-5, 0, 0; -3, 0, 0; 0, 0, 0; 0, 0, 0; 2, 0, 0)
$ <simplified-stoichiometry-matrix>

Tai gali būti naudinga norint patikrinti ar konstruojamo modelio rezultatai atitinka kitų modelių rezultatus. Kadangi 3-4 eilutės turi tik nulines reikšmes, 3-4 medžiagos supaprastintame modelyje neatlieka jokios funkcijos, produkto formavimąsi lemia tik pirmos dvi medžiagos. Esant tokioms aplinkybės masės pasiskirstymo evoliuciją apibūdinti nėra sudėtinga -- reakcijai prasidedant skirtingų medžiagų plotai nepersidengia, tačiau veikiant difuzijai medžiagos pasiekia viena kita ir reaguoja. Reakcija vyksta intensyviausiai ten kur atstumas tarp skirtingų medžiagų yra mažiausias, t. y. ant ribos skiriančios dvi medžiagas. Apibudinta reakcijos eiga atsiskleidžia pavyzdžiuose iš @vaicekauskas2025yag. Šiuo atveju patikrinsime ar galime atkartoti apibūdintą supaprastiną reakciją naudojant stoichiometrinę matricą iš @simplified-stoichiometry-matrix[lygt.].

#figure(
  image("../assets/diagrams/simplified_reaction_dynamics_example.png", width: 75%),
  caption: [ Modelio rezultatai, kai naudojama supaprastinto cheminio modelio stoichiometrinė matrica. Reakcijoje dalyvaujančių medžiagų tankio pasiskirstymas erdvėje įvairiais laiko momentais. Modelio parametrai $k_i = 1.0$, $D_i = 10^(-2)$, diskretaus tinklelio rezoliucija $W = H = 100,$ o $Delta x = Delta y = 1/99$.],
) <simplified-frame-example>

Rezultatai matomi @simplified-frame-example sutampa su prieš tai pateiktu reakcijos aprašymų, taip pat galime pastebėt tam tikrų simetrijų, kurias lemia pasirinkta pradinė sąlyga. Jei laikysime, kad taškas (0, 0) žymi srities centrą, tuomet produkto tankio pasiskirstymas visuose laiko taškuose yra simetriškas aplink $x=0, y=0, y=x, y=-x$.

// TODO: ar išeina gauti identiškus pabaigos laiko rezultatus?

== Išplėsto modelio rezultatai ir reakcijos dinamika

#figure(
  image("../assets/diagrams/frame_example_transposed.png"),
  caption: [Modelio rezultatai, kai naudojama išplėsta stoichiometrinė matrica $bold(S)$ iš @compact-model-and-related-notation[lygt.]. Reakcijoje dalyvaujančių medžiagų tankio pasiskirstymas erdvėje įvairiais laiko momentais. Modelio parametrai $k_i = 1.0$, $D_i = 10^(-2)$, diskretaus tinklelio rezoliucija $W = H = 100,$ o $Delta x = Delta y = 1/99$. ],
) <frame-example>

@frame-example matome modelio rezultatus, kai naudojama pilna stoichiometrinė matrica. Šiuo atveju modelio rezultatas yra penkių medžiagų tankio pasiskirstymo istorija laike. Modelio parametrai šiam (kaip ir praeitam) pavyzdžiui yra parinkti atsitiktiniu būdu norint pademonstruoti reakcijoje slypinčią dinamiką. Kadangi parametrų fiziniai matai pavyzdyje neturi prasmės, todėl ir tankio reikšmių amplitudę žyminčios spalvų juostos (_angl. colorbars_) matavimo vienetų neturi.

Šį modelio rezultatą galime lyginti su prieš tai pateiktų pavyzdžiu @const-mass, kuriame matome tik masės dalies kitimą per laiką. Pirmuoju pavaizduotu laiko momentu (pirma eilutė), YAP, YAM ir YAG medžiagų beveik nėra arba jos tik pradeda formuotis. Laikui bėgant šios medžiagos difunduoja ir reaguoja tik tarpusavyje formuodamos t arpinius (YAM, YAP) ir galutinį (YAG) produktus.

Galime pastebėti, kad šį kartą sprendinys turi mažiau simetrijų negu prieš tai pademonstruoto supaprastinto modelio sprendinys (@simplified-frame-example), nors ir naudojama identiška pradinė sąlyga. Laikant tašką (0, 0) srities centru, šiuo atveju tarpiniai ir galutinis produktai turi simetrijas aplink $y=x$ ir $y=-x$ ašis. Dviejų papildomų medžiagų modeliavimas modelio sprendiniui suteikia daug sudėtingesnį elgesį. 


// Gal nereikia, tiesiog nieko nesakius pereiti prie pvz?
// Toliau paanalizuosime vieną iš pagrindinių priežasčių, kodėl 3-4 medžiagų sprendiniuose pasirodo puslankiai judantis priešingomis kryptimis ir prarandama pliuso formos simtetrija, kurią galime matyti reakcijos pradžioje.

#include "../assets/diagrams/non-symmetry/example.typ"

@non-symmetry-example vaizduojami supaprastinti modelio rezultatai, kuriuos analizuodami galime lengviau suprasti sprendinio elgesį ir kas lemia įstrižai atsiskyrusių žiedų atsiradimą. Ketvirta medžiaga formuojasi tose vietose, kur yra ir pirmos ir trečios medžiagos, šie plotai pažymėti raudonai. Svarbu pastebėti, kad $rho_4$ neturi Stokios simetrijos kaip $rho_3$ -- ji formuojasi arčiau apatiniojo kairiojo ir viršutinio dešiniojo kampo. Trečiosios medžiagos šiuose kampuose būti negali, nes ten patekusi, ji imtų reaguoti su pirmąją medžiaga, kuriuos šiuose kampuose yra ypač daug (žr. $rho_1$). Tokios saveikos su kitais dvejais kampais (viršutinis kairysis bei apatinis dešinysis) nėra -- juose nėra pirmos medžiagos, todėl trečioji medžiaga gali kauptis vykstant difuzijai, taip susiformuoja atsiskyrę žiedai .



// Dalykai kuriuos reiketu aprasyti prie modelio parametru optimizavimo:
// Kokiu metodu rasti, kodel butent toks pasirinktas
// Actual optimalus parametrai ir palyginimas su eksperimentiniais duomenimis
// Eksperimentiniai duomenys!!!
// Related performance/stats, pamineti HPC involvement
