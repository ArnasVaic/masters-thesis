= Skaitinio modelio rezultatai

#let reaction_const_unit = $$

#figure(
  image("../assets/diagrams/const-mass.png"),
  caption: [Skaitinio modelio rezultatai. Medžiagų masių procentinių dalių evoliucija laike. Naudota diskrečios erdvės rezoliucija $40 times 40$, $Delta x = Delta y approx 2.5 times 10^(-2) mu m$, laiko žingsnis -- pastovus $Delta t = 10^(-4)s$, o visas reakcijos laikas $T=10s$. Modelio parametrai $D_i = 10^(-2) mu m^2\/s $, $k_1=10.0, k_2=5.0, k_3=1.0, "kur" [k_i] = mu m^3\/("mol" dot s)$. ]
) <const-mass>

#let it-ox = $"Y"_2"O"_3$
#let al-ox = $"Al"_2"O"_3$
#let yap = $"YAlO"_3$
#let yam = $"Y"_4"Al"_2"O"_9$
#let yag = $"Y"_3"Al"_5"O"_12$

@const-mass pavaizduoti skaitinio modelio rezultatai, matome kaip laikui bėgant sistemoje keičiasi skirtingų medžiagų procentinės masės dalys. Reakcijos pradžioje 100% masės sudaro reagentai #al-ox ir #it-ox, tačiau laikui bėgant šios medžiagos reaguoja ir sudaro tarpinius junginius YAM ir YAP bei produktą YAG. Reakcijos metu naujų reagentų į sistemą nėra pridedama, todėl naturalu, kad jų kiekis sistemoje griežtai mažėja. YAP ir YAM junginiai reakcijoje yra pagaminami, tačiau ir suvartojami, todėl jų kiekis sistemoje reakcijos pradžioje išauga, o po to, lėtai nyksta.

Vienas iš svarbiausių @const-mass matomų rezultatų yra žalsva linija $Sigma$, kuri žymi visų medžiagų masės sumos santyki su pradine reagentų sumą:
// integral_Omega c_i (x,y,t)d V
$
  Sigma(t_n) = 1/m_0 sum_(i=1)^5 q_i (t_n) M_i
$

Čia $q_i$ yra medžiagų molinis kiekis diskrečiu laiko momentu $t_n$, $M_i$ yra medžiagos molinės masės, o $m_0$ pradinių medžiagų masė prieš reakcijai prasidedant. Svarbu atkreipti dėmesį į tai, kad šis dydis laikui bėgant išlieka toks pat, tai reiškia, kad sprendžiant sistemą skaitiniais metodais, per $10^5$ diskrečių laiko žingsnių neatsirado skaičiavimo paklaidų dėl kurių bendra sistemos masė galėtų pakisti.

#pagebreak(weak: true)

#figure(
  image("../assets/diagrams/frame_example.png"),
  caption: [Medžiagų molinės koncentracijos pasiskirstymas erdvėje įvairiais laiko momentais. Modelio parametrai tokie patys kaip pastovios masės demonstracijoje @const-mass išskyrus reakcijos koeficientus. Čia $k_1 = 60.0, k_2 = 30.0, k_3 = 15.0$.]
) <frame-example>

@frame-example matome kaip atrodo neagreguoti kompiuterinio modelio rezultatai -- modelio produktas yra visų penkių reakcijoje dalyvaujančių medžiagų pasiskirstymai erdvėje diskrečiais laiko momentais, tuo tarpu @const-mass pavaizduoti rezultatai buvo gauti apdorojant šiuos duomenis iš jų išgaunant medžiagų masės kiekius sistemoje.

Modelio parametrai pavyzdžiui @frame-example yra parinkti atsitiktinai norint pademonstruoti modelio rezultatus ir modeliuojamą reakcijos procesą. Kaip ir pavyzdyje @const-mass matome, kad pirmuoju pavaizduotu laiko momentu (pirmas stulpelis), 2-3 medžiagų koncentracijų nėra todėl, kad sistemoje yra tik reagentai, kurių pradinę sąlygą jau aptarėme modelio sekcijoje. Laikui bėgant šios medžiagos difunduoja ir reaguoja tik sandūroje, panašų procesą galime įsivaizduoti ir cheminėje reakcijoje, kada medžiagų dalelės pradeda tirpti aukštoje temperatūroje, kas leidžia jom reaguoti ir sanduroje sudaryti produktą YAG. Kompiuterinio modelio rezultatuose galima pastebėti subtilų tarpinių produktų nesimetriškumą $x$ ir $y$ ašimis. Šį polinkį galėtų lemti faktas, kad skirtingų medžiagų poros reaguoja skirtingu greičiu.

= Modelio parametro optimizavimas

#figure(
  table(
    columns: 7,
    [Temperatūra], [Praėjęs laikas], [#al-ox masės dalis (%), $p_1$], [#it-ox masės dalis (%), $p_2$], [(YAM) masės  dalis (%), $p_3$], [(YAP), masės dalis (%), $p_4$], [(YAG) masės dalis (%), $p_5$],
    [1300 $degree$C],[24 val.],[29.26],[18.27],[15.10],[30.76],[6.61],

    [1400 $degree$C],[6 val.],[29.48],[19.32],[14.84],[24.30],[12.05],

    [1600 $degree$C],[19 val.],[29.21],[19.37],[15.08],[24.06],[12.27]
  ),
  caption: [
    Eksperimentiniai duomenys, kuriuos paruošė Vilniaus Universiteto Chemijos ir Geomokslų fakulteto mokslininkai atlikdami YAG sintezės reakciją laboratorijoje. Lentelėje pateiktos skirtingų medžiagų procentinės masės dalys $p_i$ praėjus tam tikram laikui nuo reakcijos pradžios, kai reakcija vykdomą prie įvairių temperatūrų.
  ]
) <experimental-data>

@experimental-data vaizduoja eksperimentinius duomenis, kuriais vadovaudamiesi bandysime rasti optimalius modelio parametrus, t. y. bandysime rasti tokius modelio parametrus, kurie minimizuoja vidutinės kvadratinės paklaidos (_angl. mean squared error_) kainos funkciją:

$
  cal(L)(bold(p), hat(bold(p))) = sum_(i=1)^5 (p_i-hat(p)_i)^2
$

Čia $hat(bold(p))$ yra modelio prognozuojamos medžiagų masės dalys. Šiam tikslui pasiekti pasinaudosime VU MIF HPC infrastruktūra, kurios pagalbą galėsime leisti daugelį eksperimentu paraleliai, tokiu būdu sutrumpinant laiką, kurio reikia norint optimizuoti modelio parametrus. Modelių optimizavimui naudosime Optuna @akiba2019optuna -- atviro kodo hiperparametrų optimizavimo karkasas skirtas Python kalbai.

#let Dunit = $mu m^2 dot h^(-1)$
#let Kunit = $mu "m"^3 \/ ("mol h")$

#figure(
  table(
    columns: 2,
    [*Parameteras*], [*Reikšmė*], 
    [$D_1 (#al-ox)$], [ $ 1.0850 times 10^(-7) #Dunit$ ],
    [$D_2$ (#it-ox)], [ $3.9213 times 10^(-7) #Dunit$ ],
    [$D_3$ (YAM)], [ $2.9699 times 10^(-6) #Dunit$ ],
    [$D_4$ (YAP)], [ $4.1412 times 10^(-8) #Dunit$],
    [$D_5$ (YAG)], [ $3.1037 times 10^(-7) #Dunit$ ],
    [$k_1$], [ $1.4166 times 10^13 #Kunit$ ],
    [$k_2$], [ $6.2080 times 10^13 #Kunit$],
    [$k_3$], [ $9.2367 times 10^12 #Kunit$],
  ),
  caption: [ Modelio parametrų optimizavimo rezultatai. Parametrų paieška vykdyta VU MIF HPC. Paieškai buvo naudota 16 paraleliai veikiančių darbininkų (_angl. worker_), kiekvienas kurių atliko $100$ bandymų. Parametrų paieška užtruko 13 min 35s. ]
) <optim-results>

@optim-results vaizduoja rastą parametrų rinkinį, su kuriais kainos funkciją pasiekė mažiausią reikšmę -- 1.9634. Galime palyginti medžiagų masės dalis tarpusavyje:

#figure(
  table(
    columns: 6,
    [],[#al-ox masės dalis (%), $p_1$], [#it-ox masės dalis (%), $p_2$], [(YAM) masės  dalis (%), $p_3$], [(YAP), masės dalis (%), $p_4$], [(YAG) masės dalis (%), $p_5$],
    [Modelis], [26.59], [20.26], [14.78], [24.02], [14.35],
    [Eksperimentas], [29.21], [19.37], [15.08], [24.06], [12.27],
    [*Skirtumas*],[-3.38%], [+0.89%], [-0.3%], [-0.04%], [+2.08%]
  ),
  caption: [Eksperimento ir modelio rezultatų palyginimas. Medžiagų masės dalys, kai reakcija vyksta 1400 $degree$C temperatūroje 6 val. Paskutinėje eilutėje žymi skirtumą tarp modelio ir eksperimento masės dalių.]
) <percentage-compare>

@percentage-compare matome, kad skirtumai tikrųjų masės dalių procentų nėra dideli, tačiau praktiniam panaudojimui išlieka reikšmingi, ypatingai, produkto YAG ir #al-ox masės dalies procentai. Tai galėtų lemti keletas priežasčių -- modelis yra per paprastas ir neapima reikšmingų cheminių arba fizinių procesų vykstančių reakcijos metu, taip pat ieškant parametrų galėjo būti atliekama daugiau bandymų.


// Dalykai kuriuos reiketu aprasyti prie modelio parametru optimizavimo:
// Kokiu metodu rasti, kodel butent toks pasirinktas
// Actual optimalus parametrai ir palyginimas su eksperimentiniais duomenimis
// Eksperimentiniai duomenys!!!
// Related performance/stats, pamineti HPC involvement
