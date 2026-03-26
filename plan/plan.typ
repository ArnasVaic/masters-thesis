#import "../doc/config/style.typ": style_config
#import "../doc/config/titlepage.typ": title_page

#show: style_config("lt")

// Req. R6

#title_page(
  "Kompiuterinio modeliavimo pirmo kurso mokslo tiriamojo darbo projekto planas",
  [ 
    Medžiagų maišymo kompiuterinis modeliavimas cheminėse reakcijose \ 
    #text(size: 10pt)[Computer modeling of material mixing in chemical reactions] 
  ],
  "Arnas Vaicekauskas",
  "asist. dr. Rokas Astrauskas",
  "lt",
)

#outline(depth: 3)

#pagebreak(weak:true)

= Įvadas



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

Duomenys tyrimui bus gauti su Vilniaus Universiteto Chemijos fakulteto mokslininkų pagalba. Laboratorijoje bus vykdoma YAG sintezės reakcija, kuriai analizuoti bus pasitelktas spektrografas, iš šio prietaiso duomenų galima nustatyti produkto ir reagentų santykį skirtingais laiko momentais. Eksperimentai taip pat bus vykdomi prie skirtingų temperatūrų. Gauti duomenys leis nustatyti reakcijos modelio parametrus su kuriais rezultatai tiksliausiai atitinka eksperimentą. 

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
