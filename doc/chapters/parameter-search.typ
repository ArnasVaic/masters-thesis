#import "../config/todo.typ": todo, todo-inline

= Modelio parametrų paieška

== Pradinių sąlygų pasirinkimas

#todo[
  Key details for the text about @end-time-quartile-examples:
  - Goal: pick representative initial conditions for the parameter search, i.e. ones whose reaction end time is typical for their distribution.
  - Largest size $n = 16$ ($16 times 16 mu m$), 1000 trials per IC type, same data as @random-squares-end-time-distribution and @perlin-end-time-distribution (same model parameters, $20n times 20n$ mesh, same time step, end at 10% of reagent mass).
  - For each IC type, the trial whose end time is closest to $Q_1$, the median and $Q_3$ is chosen.
  - Random squares: $Q_1$ trial 814 ($123.4$ s), median trial 287 ($161.2$ s), $Q_3$ trial 383 ($218.0$ s).
  - Perlin ($n = 16$ lattice, $t = 0.5$): $Q_1$ trial 2 ($21.6$ s), median trial 12 ($22.6$ s), $Q_3$ trial 18 ($23.6$ s).
  - Perlin end times only take values $0.2$ s apart (the step has reached $Delta t_"max"$), so many trials tie; the lowest trial number among them is taken.
  - Visible in the figure: Perlin regions are smaller than a $1 mu m$ particle, random squares join into clusters several particles wide.
  - Script: `py/results/reaction_end_time_based_on_size/quartile_examples.py`.
]

#figure(
  image("../assets/diagrams/end-time-quartile-examples.png", width: 85%),
  caption: todo-inline[
    caption: $n = 16$ initial conditions closest to $Q_1$, median, $Q_3$ of end time; top row random squares, bottom row Perlin; $t$ under each is its end time; white $c_1$, gray $c_2$; parameters as in @random-squares-end-time-distribution.
  ],
) <end-time-quartile-examples>

= Modelio parametro optimizavimas

#let it-ox = $"Y"_2"O"_3$
#let al-ox = $"Al"_2"O"_3$
#let yap = $"YAlO"_3$
#let yam = $"Y"_4"Al"_2"O"_9$
#let yag = $"Y"_3"Al"_5"O"_12$

#figure(
  table(
    columns: 7,
    [Temperatūra],
    [Praėjęs laikas],
    [#al-ox masės dalis (%), $p_1$],
    [#it-ox masės dalis (%), $p_2$],
    [(YAM) masės  dalis (%), $p_3$],
    [(YAP), masės dalis (%), $p_4$],
    [(YAG) masės dalis (%), $p_5$],

    [1300 $degree$C], [24 val.], [29.26], [18.27], [15.10], [30.76], [6.61],

    [1400 $degree$C], [6 val.], [29.48], [19.32], [14.84], [24.30], [12.05],

    [1600 $degree$C], [19 val.], [29.21], [19.37], [15.08], [24.06], [12.27],
  ),
  caption: [
    Eksperimentiniai duomenys, kuriuos paruošė Vilniaus Universiteto Chemijos ir Geomokslų fakulteto mokslininkai atlikdami YAG sintezės reakciją laboratorijoje. Lentelėje pateiktos skirtingų medžiagų procentinės masės dalys $p_i$ praėjus tam tikram laikui nuo reakcijos pradžios, kai reakcija vykdoma prie įvairių temperatūrų.
  ],
) <experimental-data>

@experimental-data vaizduoja eksperimentinius duomenis, kuriais vadovaudamiesi bandysime rasti optimalius modelio parametrus, t. y. bandysime rasti tokius modelio parametrus, kurie minimizuoja vidutinės kvadratinės paklaidos (_angl. mean squared error_) kainos funkciją:

$
  cal(L)(bold(p), hat(bold(p))) = sum_(i=1)^5 (p_i-hat(p)_i)^2
$

Čia $hat(bold(p))$ yra modelio prognozuojamos medžiagų masės dalys. Šiam tikslui pasiekti pasinaudosime VU MIF HPC infrastruktūra, kurios pagalba galėsime leisti daugelį skaičiavimo eksperimentų paraleliai, tokiu būdu sutrumpinant laiką, kurio reikia norint optimizuoti modelio parametrus. Modelių optimizavimui naudosime Optuna @akiba2019optuna -- tai atviro kodo hiperparametrų optimizavimo karkasas skirtas Python kalbai.

#let Dunit = $mu m^2 dot h^(-1)$
#let Kunit = $mu "m"^3 \/ ("mol h")$

#figure(
  table(
    columns: 2,
    [*Parameteras*], [*Reikšmė*],
    [$D_1 (#al-ox)$], [ $1.0850 times 10^(-7) #Dunit$ ],
    [$D_2$ (#it-ox)], [ $3.9213 times 10^(-7) #Dunit$ ],
    [$D_3$ (YAM)], [ $2.9699 times 10^(-6) #Dunit$ ],
    [$D_4$ (YAP)], [ $4.1412 times 10^(-8) #Dunit$],
    [$D_5$ (YAG)], [ $3.1037 times 10^(-7) #Dunit$ ],
    [$k_1$], [ $1.4166 times 10^13 #Kunit$ ],
    [$k_2$], [ $6.2080 times 10^13 #Kunit$],
    [$k_3$], [ $9.2367 times 10^12 #Kunit$],
  ),
  caption: [ Modelio parametrų optimizavimo rezultatai. Parametrų paieška vykdyta VU MIF HPC. Paieškai buvo naudota 16 paraleliai veikiančių darbininkų (_angl. worker_), kiekvienas kurių atliko $100$ bandymų. Parametrų paieška užtruko 13 min 35s. ],
) <optim-results>

@optim-results vaizduoja rastą parametrų rinkinį, su kuriais kainos funkcija pasiekė mažiausią reikšmę -- 1.9634. Galime palyginti medžiagų masės dalis tarpusavyje:

#figure(
  table(
    columns: 6,
    [],
    [#al-ox masės dalis (%), $p_1$],
    [#it-ox masės dalis (%), $p_2$],
    [(YAM) masės  dalis (%), $p_3$],
    [(YAP), masės dalis (%), $p_4$],
    [(YAG) masės dalis (%), $p_5$],

    [Modelis], [26.59], [20.26], [14.78], [24.02], [14.35],
    [Eksperimentas], [29.21], [19.37], [15.08], [24.06], [12.27],
    [*Skirtumas*], [-3.38%], [+0.89%], [-0.3%], [-0.04%], [+2.08%],
  ),
  caption: [Eksperimento ir modelio rezultatų palyginimas. Medžiagų masės dalys, kai reakcija vyksta 1400 $degree$C temperatūroje 6 val. Paskutinėje eilutėje žymi skirtumą tarp modelio ir eksperimento masės dalių.],
) <percentage-compare>

@percentage-compare matome, kad tarp tikrųjų ir modelio prognozuojamų masės dalių nėra dideli, tačiau praktiniam panaudojimui išlieka reikšmingi, ypač produkto YAG ir #al-ox masės dalies procentai. Tai galėtų lemti keletas priežasčių -- modelis yra per paprastas ir neapima reikšmingų cheminių arba fizinių procesų, vykstančių reakcijos metu, taip pat ieškant parametrų galėjo būti atliekama daugiau bandymų.
