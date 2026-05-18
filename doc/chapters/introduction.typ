#heading(numbering: none)[Įvadas]

Itrio aliuminio granatas (YAG) yra sintetinis kristalas, kuris pasižymi pageidaujamomis optinėmis savybėmis. Ši medžiaga naudojama įvairiose srityse, pavyzdžiui, aukštos energijos šviesolaidžiuose @pang2024recent ir aukštos energijos lazeriuose @fujioka2021aln. Konkrečiai sričiai pritaikyti YAG kristalai būna legiruoti su retųjų žemių metalų jonais, kurie suteikia kristalui papildomų savybių. Minėtuose šviesolaidžiuose naudojamas YAG būna legiruotas su erbio arba iterbio jonais, o lazerių aktyviosioms terpėms gaminti dažniausiai naudojamas YAG kristalas legiruotas su neodimiu arba ceriu.

YAG kristalai turi daugybę taikymų, todėl šios medžiagos sintezės būdai yra plačiai tiriami. Keletas iš žinomų sintezės būdų yra nusodinimas (_angl. #box[co-precipitation]_) @wang2000synthesis, beslėgis sukepinimas (_angl. pressureless sintering_) @ikesue2022synthesis, zolio-gelio metodas (_angl. sol-gel_) @singlard2018sol, tačiau šiame tyrime bus nagrinėjama kietafazė (_angl. solid-state_) sintezės reakcija, kuri išsiskiria paprastu praktiniu įgyvendinimu -- itrio ir aliuminio oksidų mišinys yra kaitinamas aukštoje temperatūroje, kurioje pradeda formuotis YAG kristalai. 

Atlikti šią reakciją laboratorijoje reikalauja daug laiko ir energijos, tačiau kompiuterinis šios reakcijos modelis gali padėti greitai ir pigiai nustatyti optimalų reakcijos vykdymo laiką, temperatūrą ir pamatyti mikroskopinius procesus, kurių tiesiogiai matyti negalime dėl fizinių sąlygų reikalingų reakcijai vykdyti.

Šios reakcijos modelį sudaro fizikiniai parametrai nusakantys medžiagų difuzijos bei reagavimo greičius. Šių parametrų pasirinkimas lemia modelio rezultatų atitikimą su eksperimento rezultatais. Šiam tikslui pasiekti bus naudojami eksperimentiniu būdu gauti reakcijos duomenys, kuriuos paruoš Vilniaus Universiteto Chemijos fakulteto mokslininkai.

Šio *darbo tikslas* -- sudaryti dviejų dimensijų kompiuterinį kietafazės YAG sintezės reakcijos modelį ir nustatyti jo fizinius parametrus naudojantis eksperimentiniais duomenimis bei įvertinti modelio tikslumą.

Šiam tikslui pasiekti buvo iškelti šie uždaviniai: 

- Sukonstruoti matematinį YAG sintezės modelį remiantis cheminėmis reakcijomis

- Sukurti kompiuterį YAG sintezės modelį naujant C++ kalbą

- Sukurti kompiuterinio modelio sąsajas (_angl. bindings_) Pytohn kalbai

- Verifikuoti kompiuterinio modelio rezultatus

- Pritaikyti kompiuterinį modelį MIF superkompiuterio infrastruktūrai

- Įgyvendinti programinį karkasą, kuris leistu atlikti modelio parametrų paiešką lygiagretinant skaičiavimus tarp daugelio superkompiuterio skaičiavimo mazgų.

- Naudojantis sukurta programine įranga optimalius modelio parametrus