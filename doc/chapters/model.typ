#import "@preview/cetz:0.5.1": canvas, draw

= Papildytas matematinis modelis

== Modelio sudarymas

#let it-ox = $"Y"_2"O"_3$
#let al-ox = $"Al"_2"O"_3$
#let yap = $"YAlO"_3$
#let yam = $"Y"_4"Al"_2"O"_9$
#let yag = $"Y"_3"Al"_5"O"_12$

Tyrimai, kuriuose yra matematiškai modeliuojama kietafazė YAG sintezė @mackeviciusCloserLookComputer2012 @ivanauskasComputationalModellingYAG2009 @ivanauskasModellingSolidState2005a remiasi supaprastinta chemine reakcija:

$
  3#it-ox + 5#al-ox arrow.r.long 2#yag ("YAG")
$ <short-chem>

Tačiau yra žinoma, kad sintezės metu vyksta kelios reakcijos, kurių metu formuojasi tarpiniai produktai #yap (YAP) ir #yam (YAM):

$
  #al-ox + 2#it-ox  &arrow.r.long "YAM" #<reaction:1> \
  #al-ox + "YAM" &arrow.r.long 4"YAP" #<reaction:2> \
  #al-ox + 3"YAP" &arrow.r.long "YAG" #<reaction:3>
$ <long-chem>

Remiantis masės veikimo dėsniu (_angl. mass action law_) ir cheminėmis reakcijomis @reaction:1 @reaction:2 @reaction:3 galime sudaryti diferencialines lygtis, kurios nusako, kaip molinis medžiagų kiekis kinta su laiku. Molinę medžiagų masę laiko momentu $t$ žymėsime taip: $q_1 (#al-ox)$, $q_2 (#it-ox)$, $q_3 ("YAM")$, $q_4 ("YAP")$, $q_5 ("YAG")$, čia $q_i = q_i (t)$. Analogiškai žymėsime molinį medžiagų koncentracijos pasiskirstymą erdvėje $c_i = c_i (bold(x), t)$. Iš @reaction:1 gauname:
#let partial-t = var => $ (partial var) / (partial t) $
$
  #partial-t($q_1$) = -k_1q_1q_2 quad
  #partial-t($q_2$) = -2k_1q_1q_2 quad
  #partial-t($q_3$) = k_1q_1q_2
$
Iš @reaction:2:
$
  #partial-t($q_1$) = - k_2q_1q_3 quad
  #partial-t($q_3$) = - k_2q_1q_3 quad
  #partial-t($q_4$) = 4k_2q_1q_3
$
Iš @reaction:3:
$
  #partial-t($q_1$) = - k_3q_1q_4 quad
  #partial-t($q_4$) = - 3k_3q_1q_4 quad
  #partial-t($q_5$) = k_3q_1q_4
$

Čia $k_i, i = 1, 2, 3$ yra individualių reakcijų greičio konstantos. Gautas lygtis galime apjungti ir sudaryti bendrą modelį kartu jį aprašant ne per molinius medžiagų kiekius, o molines koncentracijas papildomai įtraukiant ir difuzijos procesą:

$
  (partial c_1) / (partial t) &= D_1 nabla^2 c_1 - k_1c_1c_2 - k_2c_1c_3 - k_3c_1c_4\
  (partial c_2) / (partial t) &= D_2 nabla^2 c_2 - 2k_1c_1c_2\
  (partial c_3) / (partial t) &= D_3 nabla^2 c_3 + k_1c_1c_2 - k_2c_1c_3\
  (partial c_4) / (partial t) &= D_4 nabla^2 c_4 + 4k_2c_1c_3 - 3k_3c_1c_4\
  (partial c_5) / (partial t) &= D_5 nabla^2 c_5 + k_3c_1c_4
$ <long-sytem-eqs>

Čia $D_i$ -- medžiagų difuzijos konstantos, $k_i$ -- reakcijos greičio konstantos. Sąryšis tarp molinio medžiagos kiekio $q_i$ ir molinės medžiagos koncentracijos $c_i$ yra štai toks:

$
  q_i (t) = integral_Omega c_i (x, y,t) d V
$

Čia $Omega$ yra erdvės sritis, kurioje modeliuojame reakciją. Apjungiant lygtis @long-sytem-eqs[], sistemą galima užrašyti ir glaustesniu formatu:

$
  (partial bold(c)) / (partial t) &= bold(D) dot.o nabla^2 bold(c) + bold(S) dot bold(phi)(bold(c)), quad bold(S) = mat(-1, -1, -1; -2, 0, 0; 1, -1, 0; 0, 4, -3;0, 0, 1), quad  bold(phi)(bold(c)) = vec(k_1 c_1 c_2, k_2 c_1 c_3, k_3 c_1 c_4)
$

kur $bold(D) = (D_1, D_2, D_3, D_4, D_5)$.

== Pradinė ir kraštinė sąlygos

Kaip ir susijusiuose tyrimuose @mackeviciusCloserLookComputer2012 @ivanauskasComputationalModellingYAG2009 @ivanauskasModellingSolidState2005a darysime prielaidą, kad reagentų dalelės yra vienodai pasiskirsčiusios po erdvę ir yra apytiksliai kvadrato formos, dėl šios priežasties tyrimų autoriai teigia, kad užtenka modeliuoti erdvės sritį, kurios tūris yra 1 $mu m^3$. Reikia pastebėti, kad tyrimų autoriai modeliuodami reakciją daro prielaidą, kad abiejų medžiagų dalelės yra vienodo turio -- $1 mu m^3$, tokias prielaidas darysime ir mes, kaip parodyta @initial-condition

#let mixture-pefect() = {

  // draw.set-style(
  //   grid: (
  //     stroke: 2pt
  //   )
  // )

  // draw.grid((0, 0), (5, 5), step: 5/3)
  // 
  // for x in range(n) {
  let n = 3
  let cell = 1.25
  for x in range(n) {
    for y in range(n) {

      let color = if calc.rem(x + y, 2) == 0 {
          rgb("#ffffff")
        } else {
          rgb("#dededeff")
        }

      draw.rect(
        (x * cell, y * cell),
        ((x + 1) * cell, (y + 1) * cell),
        fill: color,
        stroke: 1pt,
      )
    }
  }

  draw.rect(
    (1.25/2, 1.25/2),
    (1.5 * 1.25 , 1.5 * 1.25),
    stroke: (dash: "dashed")
  )

  draw.line((0.1,-0.2), (1.25/2+0.5, 1.25/2), stroke: (dash: "dashed"))

  draw.content((0, -0.5), [
      #set text(size: 16pt)
      $Omega$
    ])
}

#figure(
  grid(columns: 5, gutter: 20pt,
  image("../assets/diagrams/mixture-rough.svg"),
  v(60pt) +
  canvas({
    draw.line((0, 0), (1, 0), mark: (end: ">>"), stroke: 1pt)
  }),
  canvas({
    mixture-pefect()
  }),
  v(60pt) +
  canvas({
    draw.line((0, 0), (1, 0), mark: (end: ">>"), stroke: 1pt)
  }),
  canvas({

    let color = rgb("dededeff")

    draw.rect((0, 0), (2, 2), stroke: 1pt)
    draw.rect((0, 2), (2, 4), stroke: 1pt, fill: color)
    draw.rect((2, 0), (4, 2), stroke: 1pt, fill: color)
    draw.rect((2, 2), (4, 4), stroke: 1pt)

    draw.content((1, 1), $c^0_1$)
    draw.content((3, 3), $c^0_1$)
    draw.content((1, 3), $c^0_2$)
    draw.content((3, 1), $c^0_2$)

    draw.content((2, -0.5), $1 mu m$)
    draw.content((-0.5, 2), $1 mu m$)
  })
  ),
  caption: [Kairėje -- oksidų mišinio iliustracija, dalelės pasiskirsčiusios vienodai ir tolygiai. Centre -- idealiuotas mišinio modelis, dalelės yra kvadrato formos ir vienodo dydžio. Dešinėje -- idealizuoto modelio dalis $Omega$ iš vidurinės iliustracijos, kurią modeliuojame. Tamsesnis plotas žymi aliuminio oksido daleles, o šviesesnis -- itrio oksido daleles. Pradinių reagentų molinę koncentraciją pradiniu laiko momentu atitinkamai žymėsime $c^0_1$ (#al-ox) ir $c^0_2$ (#it-ox)]
) <initial-condition>

Sukonstruotam matematiniam modeliui taikysime Neumano kraštinę sąlygą matomą @math-boundary-cond[lygt.], kuri apibrėžia medžiagų nepratekėjimą srities paviršiaus normalių kryptimi. Šios kraštinės vizualizacija pateikta @boundary-condition

$
nabla c_i (bold(x), t) dot harpoon(n) = 0, quad (bold(x), t) in partial Omega times [0, T]
$ <math-boundary-cond>

Čia $partial Omega$ yra srities $Omega$ paviršius, o $T$ -- proceso trukmė.

#figure(
  canvas({
    let color = rgb("dededeff")

    let cell = 1.25
    let arrow_pad = 0.5
    let arrow_length = 1

    draw.rect((0, 0), (cell, cell), stroke: 1pt)
    draw.rect((0, cell), (cell, 2 * cell), stroke: 1pt, fill: color)
    draw.rect((cell, 0), (2 * cell, cell), stroke: 1pt, fill: color)
    draw.rect((cell, cell), (2 * cell, 2 * cell), stroke: 1pt)

    
    draw.line(
      (-arrow_pad, cell), 
      (-arrow_pad -arrow_length, cell), 
      mark: (end: ">>"), 
      stroke: 1pt, 
      name: "west-arrow"
    )
    draw.content(
      ("west-arrow.end"),
      anchor: "south",
      padding: (0.3, 0),
      $partial/ (partial x) c_i = 0$
    )
    
    draw.line(
      (2*cell + arrow_pad, cell), 
      (2*cell + arrow_pad + arrow_length, cell), 
      mark: (end: ">>"), 
      stroke: 1pt, 
      name: "east-arrow"
    )
    draw.content(
      ("east-arrow.end"),
      anchor: "south",
      padding: (0.3, 0),
      $partial/ (partial x) c_i = 0$
    )

    draw.line(
      (cell, -arrow_pad), 
      (cell, -arrow_pad -arrow_length), 
      mark: (end: ">>"), 
      stroke: 1pt, 
      name: "south-arrow"
    )
    draw.content(
      ("south-arrow.end"),
      anchor: "south-east",
      padding: (0.3, 0.3),
      $partial/ (partial x) c_i = 0$
    )
    
    draw.line(
      (cell, 2*cell + arrow_pad), 
      (cell, 2*cell + arrow_pad + arrow_length), 
      mark: (end: ">>"), 
      stroke: 1pt, 
      name: "north-arrow"
    )
    draw.content(
      ("north-arrow.end"),
      anchor: "north-east",
      padding: (0.3, 0.3),
      $partial/ (partial x) c_i = 0$
    )

    draw.content((1.25/2, 1.25/2), $c^0_1$)
    draw.content((3*1.25/2, 3*1.25/2), $c^0_1$)
    draw.content((1.25/2, 3*1.25/2), $c^0_2$)
    draw.content((3*1.25/2, 1.25/2), $c^0_2$)
  }),
  caption: [Modeliuojamai kvadratinei sričiai pritaikyta Neumano kraštinė sąlyga.],
) <boundary-condition>

Verta paminėti, kad pradinėje sąlygoje naudojamos pradinių medžiagų molinės koncentracijos $c^0_1$ ir $c^0_2$ atitinka stoichiometrinę sąlygą -- šių medžiagų santykis toks, kad reakcijos eigoje abi medžiagos visiškai sureaguotų. Šis santykis yra $5 : 3$, jis gali būti išvestas iš supaprastintos cheminės reakcijos @short-chem[lygt.] arba iš pilnų cheminių lygčių @long-chem[]. Konkrečias $c^0_1$ ir $c^0_2$ reikšmes galime pasirinkti pagal fizinių medžiagų tankius ir molines mases:

$
  c^0_1 = c_(#al-ox) = rho_(#al-ox) / M_(#al-ox) = (3.987 " g cm"^(-3)) / (101.96 " g mol"^(-1)) = 3.91 times 10^(-14) "mol" / (mu"m"^3)\

  c^0_2 = 3/5 c^0_1
$

