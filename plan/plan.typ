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

= Metodologija

Šiame tyrime bus pasitelkta kompiuteriniu modeliavimu pagrįsta metodologija, norint surasti modelio parametrus, kurie geriausiai apibūdina realius duomenis bus atliekama didelis kiekis skaičiavimų pasitelkiant MIF superkompiuterį.

== Naudojami įrankiai

Kompiuterinis modelis apibūdinantis kietafazę YAG reakcija bus sudaromas specialiai šiam tyrimui pasitelkiant egzistuojančias technologijas leidžiančias išnaudoti MIF superkompiuterio resursus efektyviam darbui. Modelio programinis kodas bus rašomas kalba Julia, naudojant šios kalbos ekosistemoje egzistuojančius paketus įvairiems tikslams:
- LinearAlgebra.jl -- efektyviam tiesinės algebros uždavinių sprendimui
- MPI.jl -- žinučių perdavimo sąsaja, kuri apibrėžia standartą, kaip programa  superkompiuteryje bendrauja tarpusavyje tarp skirtingų skaičiavimo vienetų
- CairoMakie.jl @DanischKrumbiegel2021 -- paketas leidžiantis sudaryti aukštos kokybės duomenų vizualizacijas
- Daug kitų.
- 

= Duomenys ir resursai

= Projekto valdymas ir rezultatai

= Įvertinimas ir sekantys žingsniai



#bibliography("references.bib")
