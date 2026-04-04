= Literatūros apžvalga

Kietafazės YAG sintezės modeliavimas nėra nauja sritis, šios reakcijos modeliai yra aktyviai tiriami @vsumskas2026yttrium. Šis modelis yra pagrįstas F. Ivanausko et al. pasiūlytu reakcijos-difuzijos modeliu @ivanauskasModellingSolidState2005a, kurio fiziniai parametrai buvo rasti susijusiuose tyrimuose @mackeviciusCloserLookComputer2012 @ivanauskasComputationalModellingYAG2009. Šiame darbe modeliuojamas cheminis procesas atrodo štai taip: ruošiant eksperimentą yra sudaromas homogeniškas ir stoichiometrinis aliuminio ($"Al"_2"O"_3$) ir itrio ($"Y"_2"O"_3$) oksidų miltelių mišinys. Abiejų oksidų milteliai yra sutrinti taip, kad vidutinis dalelių tūris būtų 1 $mu m^3$. Mišinys yra kaitinamas krosnyje 1000$degree$C, 1200$degree$C, 1600$degree$C temperatūrose kelias dešimtis valandų, per kurias susiformuoja YAG kristalai. Yra žinoma, kad mechaninis maišymas gali pagreitinti reakcijos trukmę, todėl naujesniuose tyrimuose šis procesas yra įtraukiamas į modelį @vsumskas2026yttrium. Tyrimuose procesas yra modeliuojamas kaip trijų netiesinių diferencialinių lygčių sistema:

$
(partial c_i) / (partial t) = D_i nabla^2 c_i + alpha_i k c_1 c_2, quad bold(alpha) = (-3, -5, 2), quad i = 1, 2, 3
$ <eq>

Čia $c_i = c_i (bold(x), t)$ yra medžiagų koncentracijos taške $bold(x)$ laiko momentu $t$. Medžiagos sunumeruotos taip: itrio oksidas ($i = 1$), aliuminio oksidas ($i = 2$) ir YAG ($i = 3$). $D_i$ -- medžiagų difuzijos konstantos, o $k$ -- reakcijos greičio konstanta. 

Laikoma, kad metalų dalelės yra tolygiai pasiskirsčiusios po erdvę, todėl modeliuojama tik maža, vienos dalelės dydžio sritis.

Straipsnyje sistema sprendžiama standartiniu Oilerio metodu (_angl. Euler method_), tačiau dviejų dimensijų modeliams egzistuoja efektyvesni metodai, pavyzdžiui neišreikštinis kintamosios krypties metodas (_angl. alternating direction implicit, ADI_), kurį pritaikius kartu su laiko žingsnio didinimo strategija galima efektyviai modeliuoti eksponentiškai didesnes erdves su tokia pačia diskrečių taškų rezoliucija @vaicekauskas2025yag. Tyrime YAG sintezę modeliuosime remdamiesi šiuo matematiniu modeliu.

Yra žinoma, kad šioje sintezės reakcijoje formuojasi tarpiniai junginiai -- itrio aliuminio perovskitas (YAP) bei monoklininis itrio aluminatas (YAM) @kupp2014particle, tačiau šis modelis į tai neatsižvelgia. Jei krosnies temperatūra nėra pakankamai aukšta, šie dariniai reakcijos eigoje nedingsta, kas ženkliai sumažina kristalo kokybę. Šiame tyrime taip pat buvo ištirta kaip nuo dalelių dydžio priklauso galutinio produkto išeiga -- nustatyta, kad optimaliausi dalelių dydžiai yra 110nm itrio oksido dalelėms, o aliuminio oksido -- 90nm, tokiu atveju vykdant reakciją prie 1450$degree$C galima pasiekti 93% YAG turinio pagal tūrį.
