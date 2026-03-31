#import "config/style.typ": style_config
#import "config/titlepage.typ": title_page

#show: style_config("lt")

// Req. R6

#title_page(
  "Kompiuterinio modeliavimo pirmo kurso mokslo tiriamojo darbo projekto planas",
  [ 
    // Medžiagų maišymo kompiuterinis modeliavimas cheminėse reakcijose 
    Kietafazės YAG sintezės reakcijos parametrų nustatymas kompiuteriniais modeliais \ 
    #text(size: 10pt)[
      // Computer modeling of material mixing in chemical reactions
      Determination of reaction parameters for solid-phase YAG synthesis using computer models
      ] 
  ],
  "Arnas Vaicekauskas",
  "asist. dr. Rokas Astrauskas",
  "lt",
)

#outline(depth: 3)

#pagebreak(weak:true)

= Įvadas

Itrio aliuminio granatas (YAG) yra sintetinis kristalas, kuris pasižymi pageidaujamomis optinėmis savybėmis. Ši medžiaga naudojama įvairiose srityse, pavyzdžiui, aukštos energijos šviesolaidžiuose @pang2024recent ir aukštos energijos lazeriuose @fujioka2021aln. Konkrečiai sričiai pritaikyti YAG kristalai būna legiruoti su retųjų žemių metalų jonais, kurie suteikia kristalui papildomų savybių. Minėtuose šviesolaidžiuose naudojamas YAG būna legiruotas su erbio arba iterbio jonais, o lazerių aktyviosioms terpėms gaminti dažniausiai naudojamas YAG kristalas legiruotas su neodimiu arba ceriu.

YAG kristalai turi daugybę taikymų, todėl šios medžiagos sintezės būdai yra plačiai tiriami. Keletas iš žinomų sintezės būdų yra nusodinimas (_angl. #box[co-precipitation]_) @wang2000synthesis, beslėgis sukepinimas (_angl. pressureless sintering_) @ikesue2022synthesis, zolio-gelio metodas (_angl. sol-gel_) @singlard2018sol, tačiau šiame tyrime bus nagrinėjama kietafazė (_angl. solid-state_) sintezės reakcija, kuri išsiskiria paprastu praktiniu įgyvendinimu -- itrio ir aliuminio oksidų mišinys yra kaitinamas aukštoje temperatūroje, kurioje pradeda formuotis YAG kristalai. 

Atlikti šią reakciją laboratorijoje reikalauja daug laiko ir energijos, tačiau kompiuterinis šios reakcijos modelis gali padėti greitai ir pigiai nustatyti optimalų reakcijos vykdymo laiką, temperatūrą ir pamatyti mikroskopinius procesus, kurių tiesiogiai matyti negalime dėl fizinių sąlygų reikalingų reakcijai vykdyti.

Šios reakcijos modelį sudaro keletas fizikinių parametrų, kuriuos būtina nustatyti norint, kad modelio rezultatai atitiktų fizinius rezultatus. Šiam tikslui pasiekti bus naudojami eksperimentiniu būdu gauti reakcijos duomenys, kuriuos paruoš Vilniaus Universiteto Chemijos fakulteto mokslininkai.

= Tyrimo tikslas

Šio *darbo tikslas* -- sudaryti kompiuterinį kietafazės YAG sintezės reakcijos modelį ir nustatyti jo fizinius parametrus naudojantis eksperimentiniais duomenimis bei įvertinti modelio tikslumą.

== Uždaviniai

- Įgyvendinti kompiuterinį modelį pritaikytą MIF superkompiuteriui, kuris spręstų diferencialinių lygčių sistema aprašyta YAG sintezės reakciją.

- Patobulinti kompiuterinį modelį -- modeliuoti sumažėjusią difuziją vietose, kuriose YAG koncentracija yra padidėjusi.

- Įgyvendinti programinį karkasą, kuris leistu atlikti parametrų paiešką lygiagretinant skaičiavimus tarp daugelio superkompiuterio skaičiavimo mazgų.

- Naudojant kompiuterinį modelį surasti optimalius modelio parametrus

#pagebreak()

= Literatūros apžvalga ir teorinis karkasas

// Reakcijos detalės
// Modeliavimo būdai
// Mūsų pasirinktas
Kietafazės YAG sintezės modeliavimas nėra nauja sritis, šios reakcijos modelį sudarė F. Ivanauskas et al. @ivanauskasModellingSolidState2005a, kuris ir toliau buvo naudojamas susijusiuose tyrimuose @mackeviciusCloserLookComputer2012 @ivanauskasComputationalModellingYAG2009. Šiame darbe modeliuojamas cheminis procesas atrodo štai taip: ruošiant eksperimentą yra sudaromas homogeniškas ir stoichiometrinis aliuminio ($"Al"_2"O"_3$) ir itrio ($"Y"_2"O"_3$) oksidų miltelių mišinys. Abiejų oksidų milteliai yra sutrinti taip, kad vidutinis dalelių tūris būtų 1 $mu m^3$. Mišinys yra kaitinamas krosnyje 1000$degree$C, 1200$degree$C, 1600$degree$C temperatūrose kelias dešimtis valandų, per kurias susiformuoja YAG kristalai. Tyrimuose procesas yra modeliuojamas kaip trijų netiesinių diferencialinių lygčių sistema:

$
(partial c_i) / (partial t) = D_i nabla^2 c_i + alpha_i k c_1 c_2, quad bold(alpha) = (-3, -5, 2), quad i = 1, 2, 3
$ <eq>

Čia $c_i = c_i (bold(x), t)$ yra medžiagų koncentracijos taške $bold(x)$ laiko momentu $t$. Medžiagos sunumeruotos taip: itrio oksidas ($i = 1$), aliuminio oksidas ($i = 2$) ir YAG ($i = 3$). $D_i$ -- medžiagų difuzijos konstantos, o $k$ -- reakcijos greičio konstanta. 

Laikoma, kad metalų dalelės yra tolygiai pasiskirsčiusios po erdvę, todėl modeliuojama tik maža, vienos dalelės dydžio sritis.

Straipsnyje sistema sprendžiama paprasčiausiu baigtinių skirtumų metodu -- Oilerio integracija, tačiau dviejų dimensijų modeliams egzistuoja efektyvesni metodai, pavyzdžiui neišreikštinis kintamosios krypties metodas (_angl. alternating direction implicit, ADI_), kurį pritaikius kartu su laiko žingsnio didinimo strategija galima efektyviai modeliuoti eksponentiškai didesnes erdves su tokia pačia diskrečių taškų rezoliucija @alma9917057149708451. Šis modelis bus naudojamas kaip pagrindas.

Yra žinoma, kad šioje sintezės reakcijoje formuojasi tarpiniai junginiai -- itrio aliuminio perovskitas (YAP) bei monoklininis itrio aluminatas (YAM) @kupp2014particle, tačiau šis modelis į tai neatsižvelgia. Jei krosnies temperatūra nėra pakankamai aukšta, šie dariniai reakcijos eigoje nedingsta, kas ženkliai sumažina kristalo kokybę. Šiame tyrime taip pat buvo ištirta kaip nuo dalelių dydžio priklauso galutinio produkto išeiga -- nustatyta, kad optimaliausi dalelių dydžiai yra 110nm itrio oksido dalelėms, o aliuminio oksido -- 90nm, tokiu atveju vykdant reakciją prie 1450$degree$C galima pasiekti 93% YAG turinio pagal tūrį.

= Metodologija

Šiame tyrime bus taikoma kompiuteriniu modeliavimu pagrįsta metodologija. Tyrimo tikslas -- surasti optimalius modelio parametrus, su kuriais modelio rezultatai yra tiksliausi lyginant su eksperimentiniais duomenimis.  Šiam tikslui pasiekti bus pasitelktas kompiuterinis modelis efektyviai sprendžiantis kietafazę YAG sintezės reakciją apibūdinančią diferencialinių lygčių sistemą.

// Matematinio modelio sudarymas nėra šio tyrimo dalis ir bus atliekama kartu su darbo vadovu bei kitais mokslininkais nagrinėjančiais šią temą.

== Naudojami įrankiai

Kompiuterinis modelis apibūdinantis kietafazę YAG reakciją bus sudaromas specialiai šiam tyrimui pasitelkiant egzistuojančias technologijas leidžiančias išnaudoti MIF superkompiuterio resursus efektyviam skaičiavimui. Modelio programinis kodas bus rašomas kalba Julia, naudojant šios kalbos ekosistemoje egzistuojančius paketus įvairiems tikslams:
- LinearAlgebra.jl -- efektyviam tiesinės algebros uždavinių sprendimui
- MPI.jl -- žinučių perdavimo sąsaja, kuri apibrėžia standartą, kaip programa superkompiuteryje bendrauja tarpusavyje tarp skirtingų skaičiavimo vienetų
- CairoMakie.jl @DanischKrumbiegel2021 -- paketas leidžiantis sudaryti aukštos kokybės duomenų vizualizacijas
- ir daug kitų.

= Tyrimo duomenys

Duomenys tyrimui bus gauti bendradarbiaujant su Vilniaus Universiteto Chemijos fakulteto mokslininkų pagalba. Laboratorijoje bus vykdoma YAG sintezės reakcija, kuriai analizuoti bus pasitelktas spektrografas, iš šio prietaiso duomenų galima nustatyti produkto ir reagentų santykį skirtingais laiko momentais. Eksperimentai taip pat bus vykdomi prie skirtingų temperatūrų.

== Terminas
Duomenys bus paruošti per ateinantį mėnesį t. y. iki 2026-05-01.

== Resursai

Kadangi cheminius eksperimentus atlieka VU CHF mokslininkai, resursų klausimo asmeniškai spręsti nereikia.

= Projekto valdymas

Norint užtikrinti projekto sėkmę, tyrimas yra išskaidytas į tikslias užduotis, kurios turi terminus (@tasks).

#figure(

  table(
    columns: 2,
    [*Užduotis*], [*Planuojama užbaigti*],
    [ Kompiuterinis modelis paremtas egzistuojančiu matematiniu modeliu ], [ 2026-04-01 ],
    [ Kompiuterinis modelis paremtas nauju, sudėtingesniu matematiniu modeliu ], [ 2026-04-15 ],
    [ Papildomas karkasas parametrų paieškai ], [ 2026-05-01 ],
    [ Pagrindinių tyrimo rezultatų sudarymas -- optimalių modelio parametrų paieška remiantis eksperimentinių rezultatų duomenimis ], [ 2026-05-15 ],

  ),

  caption: [ Mokslo tiriamojo darbo projekto užduočių ir terminų sąrašas]
) <tasks>

= Įsivertinimas ir tolimesni tyrimai

== Sėkmės kriterijus

Pagrindinis šio tyrimo sėkmės vertinimo kriterijus yra kompiuterinio modelio rezultatų panašumas į eksperimentinius duomenis -- jei vidutinė kvadratinė paklaida neviršija iš anksto nustatyto slenksčio, tai reiškia, kad tyrimo tikslas bus išpildytas.
== Tolimesni tyrimai

Šiame tyrime naudojamas modelis nebūtinai yra iki galo tikslus, pavyzdžiui: yra žinoma, kad reakcijos metu, reaguojant itrio ir aliuminio oksidams produktas (YAG) susidaro ties šių dalelių sandūra, kur jis stabdo tolimesnę reagentų difuziją @dabulyte2022influence, todėl galima teigti, kad difuzijos konstantos priklauso nuo produkto koncentracijos erdvėje. Toks modelis būtų daug sudėtingesnis, tačiau tai galėtų lemti tikslesnius rezultatus ir todėl toks tyrimas būtų aktualus.


#bibliography("plan-references.bib")
