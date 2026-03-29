#import "../doc/config/style.typ": style_config
#import "../doc/config/titlepage.typ": title_page

#show: style_config("lt")

// Req. R6

#title_page(
  "Kompiuterinio modeliavimo pirmo kurso mokslo tiriamojo darbo projekto planas",
  [ 
    // Medžiagų maišymo kompiuterinis modeliavimas cheminėse reakcijose 
    Kietafazės YAG sintezės reakcijos kompiuterinis modeliavimas \ 
    #text(size: 10pt)[Computer modeling of material mixing in chemical reactions] 
  ],
  "Arnas Vaicekauskas",
  "asist. dr. Rokas Astrauskas",
  "lt",
)

#outline(depth: 3)

#pagebreak(weak:true)

= Įvadas

Itrio aliuminio granatas (YAG) yra sintetinis kristalas, kuris pasižymi pageidaujamomis optinėmis savybėmis. Ši medžiaga naudojama įvairiose srityse, pavyzdžiui, aukštos energijos šviesolaidžiuose @pang2024recent ir aukštos energijos lazeriuose @fujioka2021aln. Pačios naudingiausios YAG optinės savybės atsiskleidžia legiruojant šį kristalą su retų medžiagų jonais -- šviesolaidžiuose naudojamas YAG būna legiruotas su erbio arba iterbio jonais, o lazeriams gaminti dažniausiai naudojamas neodimio jonais legiruotas YAG kristalas.

Plačios šio kristalo pritaikymo galimybės lemia poreikį efektyviam sintezės procesui. Būdų sintezuoti šią medžiagą yra žinomą keletas, pavyzdžiui bendras nusodinimas (_angl. #box[co-precipitation]_) @wang2000synthesis, beslėgis sukepinimas (_angl. pressureless sintering_) @ikesue2022synthesis. Šiame tyrime bus nagrinėjama kietafazė (_angl. solid-state_) sintezės reakcija, kurios metu yra sudaromas homogeninis ir stoichiometrinis aliuminio ($"Al"_2"O"_3$) ir itrio ($"Y"_2"O"_3$) oksidų miltelių mišinys. Abiejų oksidų milteliai yra sutrinti taip, kad vidutinis dalelių dydis yra 1 $mu m^3$. Mišinys yra kaitinamas krosnyje 1600$degree$C temperatūroje kelias dešimtis valandų per kurias susiformuoja YAG kristalai.

Atlikti šią reakciją laboratorijoje reikia daug laiko ir energijos. Kompiuterinis modelis gali padėti nustatyti optimalų reakcijos laiką, temperatūra, pamatyti procesus, kurių tiesiogiai matyti negalime dėl fizinių sąlygų reikalingų reakcijai. Matematinis modelis šiai reakcijai jau nagrinėtas @mackeviciusCloserLookComputer2012 @ivanauskasComputationalModellingYAG2009 @ivanauskasModellingSolidState2005a, jo pagrindas yra reakcijos-difuzijos sistema su netiesiniais nariais, kurie modeliuoja reagentų virsmą į produktą. Sistema bendru atveju yra sprendžiama baigtinių skirtumų metodu, tačiau dviejų dimensijų atveju, efektyvesniam sprendimui galima panaudoti neišreikštinį kintamosios krypties metodą (_angl. alternating direction implicit, ADI_) kartu su laiko žingsnio strategija, kurios metu žingsnio dydis didinamas geometrinės progresijos pagrindu @alma9917057149708451.

Yra žinoma, kad šioje sintezės reakcijoje, skirtingoje temperatūroje formuojasi ir kiti produktai -- itrio aliuminio perovskitas (YAP) bei monoklininis itrio aluminatas (YAM) @kupp2014particle, tačiau anksčiau minėtas modelis į tai neatsižvelgia. Šiame tyrime mes naudosime papildytą matematinį modelį, kuris numato ir šių medžiagų poveikį reakcijai.

// , kur optiniai kabeliai pagaminti iš YAG kristalų legiruoti su $"Er"^(3+)$ pasireiškia ženkliai sumažėjusiu foto-elastiniu (_angl. fotoelastic_) koeficientu lyginant su standartiniais kabeliais, kurie yra pagaminti iš silico dioksido skaidulų. Taip pat . 



= Tyrimo tikslai ir klausimai

== Tikslai

// Suprojektuoti ir suprogramuoti kompiuterinį modelį, kuris efektyviai spręstų diferencialinių lygčių sistemas apibūdinančias YAG sintezės reakciją.

- Nustatyti ar egzistuojančio YAG sintezės modelio rezultatai atitinka eksperimentinius duomenis
- Nustatyti naujas egzistuojančio modelio fizines konstantas naudojant tikroviškesnę pradinę sąlygą

== Tyrimo klausimai

- Kaip kitokios pradinės sąlygos pasirinkimas 

== Apimtis

= Literatūros apžvalga ir teorinis karkasas

YAG sintezės reakcijos modeliavimas nėra nauja tyrimų sritis. 

= Metodologija

Šiame tyrime bus pasitelkta kompiuteriniu modeliavimu pagrįsta metodologija. Tyrimo tikslas -- surasti optimalius modelio parametrus, su kuriais modelio rezultatai yra arčiausiai eksperimentinių duomenų. Šiam tikslui pasiekti bus pasitelktas kompiuterinis modelis efektyviai sprendžiantis kietafazę YAG sintezės reakciją apibūdinančią diferencialinių lygčių sistemą.

Matematinio modelio sudarymas nėra šio tyrimo dalis ir bus atliekama kartu su darbo vadovu bei kitais mokslininkais nagrinėjančiais šią temą.

== Naudojami įrankiai

Kompiuterinis modelis apibūdinantis kietafazę YAG reakcija bus sudaromas specialiai šiam tyrimui pasitelkiant egzistuojančias technologijas leidžiančias išnaudoti MIF superkompiuterio resursus efektyviam darbui. Modelio programinis kodas bus rašomas kalba Julia, naudojant šios kalbos ekosistemoje egzistuojančius paketus įvairiems tikslams:
- LinearAlgebra.jl -- efektyviam tiesinės algebros uždavinių sprendimui
- MPI.jl -- žinučių perdavimo sąsaja, kuri apibrėžia standartą, kaip programa  superkompiuteryje bendrauja tarpusavyje tarp skirtingų skaičiavimo vienetų
- CairoMakie.jl @DanischKrumbiegel2021 -- paketas leidžiantis sudaryti aukštos kokybės duomenų vizualizacijas
- ir daug kitų.

= Tyrimo duomenys

Duomenys tyrimui bus gauti su Vilniaus Universiteto Chemijos fakulteto mokslininkų pagalba. Laboratorijoje bus vykdoma YAG sintezės reakcija, kuriai analizuoti bus pasitelktas spektrografas, iš šio prietaiso duomenų galima nustatyti produkto ir reagentų santykį skirtingais laiko momentais. Eksperimentai taip pat bus vykdomi prie skirtingų temperatūrų. Gauti duomenys leis nustatyti reakcijos modelio parametrus su kuriais modelio nuspėjamas produkto kiekis tiksliausiai atitinka eksperimento rezultatus. 

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

Pagrindinis šio tyrimo sėkmės vertinimo kriterijus yra kompiuterinio modelio rezultatų panašumas į eksperimentinius duomenis -- jei eksperimento duomenys atitiks trendą, kuris bus matomas modelio rezultatuose, o skirtumas tarp jų bus mažesnis nei nustatyta paklaida, tai reiškia, kad tyrimo tikslas bus išpildytas.
== Tolimesni tyrimai

Šiame tyrime naudojamas modelis nebūtinai yra iki galo tikslus, pavyzdžiui: yra žinoma, kad  reakcijos metu, reaguojant itrio ir aliuminio oksidams produktas (YAG) susidaro ties šių dalelių sandūra, kur jis stabdo tolimesnę reagentų difuziją @dabulyte2022influence, todėl galima teigti, kad difuzijos konstantos yra funkcijos, kurios priklauso nuo produkto koncentracijos erdvėje. Toks modelis būtų daug sudėtingesnis, tačiau tai galėtų lemti tikslesnius rezultatus ir todėl toks tyrimas būtų aktualus.


#bibliography("references.bib")
