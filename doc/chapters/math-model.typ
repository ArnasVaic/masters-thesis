= Papildytas matematinis modelis

== Modelio sudarymas

#let it-ox = $"Y"_2"O"_3$
#let al-ox = $"Al"_2"O"_3$
#let yap = $"YAlO"_3$
#let yam = $"Y"_4"Al"_2"O"_9$
#let yag = $"Y"_3"Al"_5"O"_12$

Tyrimai, kuriuose yra matematiškai modeliuojama kietafazė YAG sintezė @mackeviciusCloserLookComputer2012 @ivanauskasComputationalModellingYAG2009 @ivanauskasModellingSolidState2005a remiasi supaprastina chemine reakcija:

$
  3#it-ox + 5#al-ox arrow.r.long 2#yag ("YAG")
$

Tačiau yra žinoma, kad sintezės metu vyksta kelios reakcijos, kurių metu formuojasi tarpiniai produktai #yap (YAP) ir #yam (YAM):

$
  #al-ox + 2#it-ox  &arrow.r.long "YAM" #<reaction:1> \
  #al-ox + "YAM" &arrow.r.long 4"YAP" #<reaction:2> \
  #al-ox + 3"YAP" &arrow.r.long "YAG" #<reaction:3>
$ 

Remiantis masės veikimo dėsniu (_angl. mass action law_) ir cheminėmis reakcijomis @reaction:1 @reaction:2 @reaction:3 galime sudaryti diferencialines lygtis, kurios nusako kaip molinis medžiagų kiekis kinta su laiku. Molinę medžiagų masę laiko momentu $t$ žymėsime taip: $q_1 (#al-ox)$, $q_2 (#it-ox)$, $q_3 ("YAM")$, $q_4 ("YAP")$, $q_5 ("YAG")$, čia $q_i = q_i (t)$. Analogiškai žymėsime molinį medžiagų konkrentracijos pasiskirstymą erdvėje $c_i = c_i (bold(x), t)$. Iš @reaction:1 gauname:

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

Čia $k_i, i = 1, 2, 3$ yra individualių reakcijų greičio konstantos. Gautas lygtis galime apjungti ir sudaryti bendra modelį kartu jį aprašant ne per molinius medžiagų kiekius, o molines koncentracijas:

$
  (partial c_1) / (partial t) &= D_1 nabla^2 c_1 - k_1c_1c_2 - k_2c_1c_3 - k_3c_1c_4\
  (partial c_2) / (partial t) &= D_2 nabla^2 c_2 - 2k_1c_1c_2\
  (partial c_3) / (partial t) &= D_3 nabla^2 c_3 + k_1c_1c_2 - k_2c_1c_3\
  (partial c_4) / (partial t) &= D_4 nabla^2 c_4 + 4k_2c_1c_3 - 3k_3c_1c_4\
  (partial c_5) / (partial t) &= D_5 nabla^2 c_5 + k_3c_1c_4
$

Čia $D_i$ -- medžiagų difuzijos konstantos, o $k_i$ -- reakcijos greičio konstantos. Sistemą galima užrašyti ir glaustesniu formatu:

$
  (partial bold(c)) / (partial t) &= bold(D) dot.o nabla^2 bold(c) + bold(S) dot bold(phi)(bold(c)), quad bold(S) = mat(-1, -1, -1; -2, 0, 0; 1, -1, 0; 0, 4, -3;0, 0, 1), quad  bold(phi)(bold(c)) = vec(k_1 c_1 c_2, k_2 c_1 c_3, k_3 c_1 c_4)
$

kur $bold(D) = (D_1, D_2, D_3, D_4, D_5)$.

== Pradinė ir kratinė sąlygos

