= Matematinis modelio sudarymas

#let it-ox = $"Y"_2"O"_3$
#let al-ox = $"Al"_2"O"_3$
#let yap = $"YAlO"_3$
#let yam = $"Y"_4"Al"_2"O"_9$
#let yag = $"Y"_3"Al"_5"O"_12$

Tyrimai, kuriuose yra matematiškai modeliuojama kietafazė YAG sintezė @mackeviciusCloserLookComputer2012 @ivanauskasComputationalModellingYAG2009 @ivanauskasModellingSolidState2005a remiasi supaprastina chemine reakcija:

$
  3#it-ox + 5#al-ox arrow.r.long 2#yag
$

Yra žinoma, kad sintezės metu vyksta kelios reakcijos, kurių metu formuojasi tarpiniai produktai #yap (YAP) ir #yam (YAM):

$
  #al-ox + 2#it-ox  &arrow.r.long "YAM" #<reaction:1> \
  #al-ox + "YAM" &arrow.r.long 4"YAP" #<reaction:2> \
  #al-ox + 3"YAP" &arrow.r.long "YAG" #<reaction:3>
$ 

Reagentus žymėsime $c_1$ (#al-ox) ir $c_2$ (#it-ox). Į modelį įtrauksime YAM ($c_3$) ir YAP $(c_4)$ medžiagų koncentracijas, o YAG koncentraciją žymėsime $c_5$. Analogiškai žymėsime šių molinę medžiagų masę laiko momentu $t$ modeliuojamoje erdvėje -- $q_i (t) = q_i$. Iš kiekvienos  reakcijos lygties galime sudaryti diferencialines lygtis apibudinančias medžiagų kiekio priklausomybę nuo laiko. Iš @reaction:1 gauname:

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

Čia $k_i, i = 1, 2, 3$ yra individualių reakcijų greičio konstantos. Gautas lygtis galime apjungti ir sudaryti bendra modelį kartu jį aprašant ne per medžiagų kiekius, o koncentracijas $c_i = c_i (x, y, t)$.

$
  (partial c_1) / (partial t) &= D_1 nabla^2 c_1 - k_1c_1c_2 - k_2c_1c_3 - k_3c_1c_4\
  (partial c_2) / (partial t) &= D_2 nabla^2 c_2 - 2k_1c_1c_2\
  (partial c_3) / (partial t) &= D_3 nabla^2 c_3 + k_1c_1c_2 - k_2c_1c_3\
  (partial c_4) / (partial t) &= D_4 nabla^2 c_4 + 4k_2c_1c_3 - 3k_3c_1c_4\
  (partial c_5) / (partial t) &= D_5 nabla^2 c_5 + k_3c_1c_4
$

Arba glaustesniu formatu

$
  (partial bold(c)) / (partial t) &= bold(D) dot.o nabla^2 bold(c) + bold(R)(bold(c)), quad bold(R)(bold(c)) = vec( - k_1c_1c_2 - k_2c_1c_3 - k_3c_1c_4, - 2k_1c_1c_2, k_1c_1c_2 - k_2c_1c_3, 4k_2c_1c_3 - 3k_3c_1c_4, k_3c_1c_4)
$

kur $bold(D) = (D_1, D_2, D_3, D_4, D_5)$.
