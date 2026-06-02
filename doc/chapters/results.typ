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

Sukonstruotas 

// Dalykai kuriuos reiketu aprasyti prie modelio parametru optimizavimo:
// Kokiu metodu rasti, kodel butent toks pasirinktas
// Actual optimalus parametrai ir palyginimas su eksperimentiniais duomenimis
// Eksperimentiniai duomenys!!!
// Related performance/stats, pamineti HPC involvement
